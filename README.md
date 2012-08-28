=======
# Tupas

Read more
- http://www.fkl.fi/teemasivut/sahkoinen_asiointi/Dokumentit/Tupas-tunnnistusperiaatteet_v20b.pdf
- http://www.fkl.fi/teemasivut/sahkoinen_asiointi/Dokumentit/Tupas-varmennepalvelu_v23c.pdf
- http://www.nordea.fi/sitemod/upload/Root/fi_org/liite/s/yritys/pdf/etunnist.pdf
- http://www.fkl.fi/teemasivut/sahkoinen_asiointi/tupas/Sivut/default.aspx

[![Build Status](https://secure.travis-ci.org/jaakkos/tupas.png?branch=master)](http://travis-ci.org/jaakkos/tupas)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jaakkos/tupas)

## In pipeline
 - [feature]: env based config
 - [bug]: invalid respose format B02K_VERS=0002&B02K_TIMESTMP=60020120822204827000001&B02K_IDNBR=0000004693&B02K_STAMP=2012082220481641964&B02K_CUSTNAME=DEMO+ANNA&B02K_KEYVERS=0001&B02K_ALG=03&B02K_CUSTID=010170-960F&B02K_CUSTTYPE=08&B02K_MAC=F0C8A198605FE1058D597B52BA0EC1F4D49CA55DC594D891A7E46D8A1857949A
 - [enhancement]: Write a gem description
 - [enhancement]: Write acceptance tests against:
  Use https://www.op.fi/op/yritysasiakkaat/maksaminen-ja-laskutus/muut-palvelut/tupas-tunnistuspalvelu/tupas-tunnistuspalvelun-testaus?cid=150294058&srcpl=3


## Done

 - [feature]: Extract provider from response and read secret from configs

## Installation

Add this line to your application's Gemfile:

    gem 'tupas'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tupas

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
