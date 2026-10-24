# Configuration used by the spec suite (copied to $HOME/.zeta/config.rb).
Config.locale              = 'en'
Config.nickname            = 'Zeta'
Config.nicks               = 'Zeta'
Config.username            = 'zeta'
Config.realname            = 'Zeta Test'
Config.prefix              = '\.'
Config.server              = '127.0.0.1'
Config.port                = 6667
Config.ssl                 = false
Config.max_messages        = 1
Config.messages_per_second = 100
Config.modes               = ''
Config.channels            = '#test'
Config.secure_mode         = 'channel'
Config.secure_channel      = '#secure'
Config.log_channel         = '#logs'
Config.oper_overide        = true
Config.debug               = false
Config.quotes_api_url      = 'quotes.example.org'
Config.quotes_api_key      = 'quote-key'
Config.secrets = {
  google: 'google-key',
  owm: 'owm-key',
  omdb: 'omdb-key',
  wolfram: 'wolfram-key',
  imgur_id: 'imgur-id'
}
Config.options = {
  join_on_invite: true,
  blacklist: { urls: ['bad.example'], users: ['spammer'], masks: [], channels: ['#quiet'] }
}
Config.plugins = %w[
  attack botinfo darkscience dbz dnsbl eightball fml fnord gif help macros movie
  noticeme pdfinfo rainbow russian_roulette seen silly snooper urban weather wiki wolfram
]
Config.custom_plugins = %w[hello]
