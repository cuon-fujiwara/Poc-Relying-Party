require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class MyOp < OmniAuth::Strategies::OAuth2
      # Give your strategy a name. 補足: ここではmy_opとしているが、任意のサイト名をつける
      option :name, 'my_op'

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        site: "http://op-web:8888",
        user_info_url: 'http://op-web:8888/oauth/userinfo',
        authorize_url: 'http://localhost:8888/oauth/authorize',
        token_url: 'http://op-web:8888/oauth/token'
      }

      # scope=openid としてリクエスト
      option :scope, 'openid'
      
      uid do
        raw_info['sub']
      end
    
      info do
        {
          email: raw_info['email']
        }
      end
    
      extra do
        # access_token.params に hash として id_token が入っている
        # (他に、token_type='Bearer', scope='openid', created_at=<timestamp> が入ってる)
        id_token = access_token['id_token']
    
        {
          raw_info: raw_info,
          id_token_payload: id_token_payload(id_token, raw_info['sub']),
          id_token: id_token
        }
      end
    
      def raw_info
        # raw_infoには、UserInfoエンドポイントから取得できる情報を入れる
        @raw_info ||= access_token.get("http://op-web:8888/oauth/userinfo").parsed
      end

      def id_token_payload(id_token, subject_from_userinfo)
        # decodeできない場合はエラーを送出する
        payload, _header = JWT.decode(
          id_token, # JWT
          nil, # key: 署名鍵を動的に探すのでnil https://github.com/jwt/ruby-jwt#finding-a-key
          true, # verify: IDトークンの検証を行う
          { # options
            algorithm: 'RS256', # 署名は公開鍵方式なので、RS256を指定
            iss: ENV['ISSUER_OF_MY_OP'],
            verify_iss: true,
            aud: ENV['CLIENT_ID_OF_MY_OP'],
            verify_aud: true,
            sub: subject_from_userinfo,
            verify_sub: true,
            verify_expiration: true,
            verify_not_before: true,
            verify_iat: true
          }
        ) do |jwt_header|
          # このブロックの中で、OPの公開鍵情報を取得
          # IDトークンのヘッダーのkidと等しい公開鍵情報を取得
          key = fetch_public_keys.find do |k|
            k['kid'] == jwt_header['kid']
          end
      
          # 等しいkidが見当たらない場合はエラー
          raise JWT::VerificationError if key.blank?
      
          # 公開鍵の作成
          # https://stackoverflow.com/a/57402656
          JWT::JWK::RSA.import(key).public_key
        end

        payload
      end

      def fetch_public_keys
        response = Faraday.get("http://op-web:8888/oauth/discovery/keys")
        keys = JSON.parse(response.body)
        keys['keys']
      end
    end
  end
end
