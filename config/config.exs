use Mix.Config
require Logger

config cipher:
  keyphrase: System.get_env("CIPHER_KEYPHRASE"),
  ivphrase: System.get_env("CIPHER_IV"),
  magic_token: System.get_env("CIPHER_TOKEN")
