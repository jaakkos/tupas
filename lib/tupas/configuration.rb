module Tupas
  class Configuration
    include Singleton

    @@defaults = {
      message_type: '701',
      version: '002',
      service_providers: [],
      return_address: '',
      cancel_address: '',
      reject_address: '',
      key_version: '4',
      key_algorith: ''
    }

    def self.defaults
      @@defaults
    end

    def initialize
      @@defaults.each_pair{|k,v| self.send("#{k}=",v)}
    end

    def self.default_logger
      logger = Logger.new(STDOUT)
      logger.progname = "omniauth"
      logger
    end

  end
end

=begin
Sanomatyyppi A01Y_ACTION_ID 3 - 4 Vakio, "701"
2. Versio A01Y_VERS 4 Esim. "0002"
3. Palveluntarjoaja A01Y_RCVID 10 -15 Asiakastunnus
4. Palvelun kieli A01Y_LANGCODE 2 ISO 639:n mukainen tunnus:
FI = Suomi
SV = Ruotsi
EN = Englanti
5. Pyynnön yksilöinti A01Y_STAMP 20 Vvvvkkpphhmmssxxxxxx
6. Yksilöintitiedon tyyppi A01Y_IDTYPE 2 ks. liite 1
7. Paluuosoite  A01Y_RETLINK 199 OK paluuosoite tunnisteelle
8. Peruuta-osoite A01Y_CANLINK 199 Paluuosoite peruutuksessa
9. Hylätty-osoite A01Y_REJLINK 199 Paluuosoite virhetilanteessa
10. Avainversio A01Y_KEYVERS 4 Avaimen sukupolvitieto
11. Algoritmi A01Y_ALG 2 01 = MD5
02 = SHA-1
03 = SHA-256
12. Tarkiste A01Y_MAC 32 - 64 Pyynnön turvatarkiste
=end