# -*- encoding : utf-8 -*-
module Tupas
  module ViewHelpers
    def tupas_buttons(identifier)
      _form = ''
      Messages::Request.new(identifier).params.each do |tupas_request_params|
        _form << "<form method='POST' action='#{tupas_request_params['url']}'>"
        _form << "<input name='A01Y_ACTION_ID' type='hidden' value='#{tupas_request_params['A01Y_ACTION_ID']}'/>"
        _form << "<input name='A01Y_VERS' type='hidden' value='#{tupas_request_params['A01Y_VERS']}'/>"
        _form << "<input name='A01Y_RCVID' type='hidden' value='#{tupas_request_params['A01Y_RCVID']}'/>"
        _form << "<input name='A01Y_LANGCODE' type='hidden' value='#{tupas_request_params['A01Y_LANGCODE']}'/>"
        _form << "<input name='A01Y_STAMP' type='hidden' value='#{tupas_request_params['A01Y_STAMP']}'/>"
        _form << "<input name='A01Y_IDTYPE' type='hidden' value='#{tupas_request_params['A01Y_IDTYPE']}'/>"
        _form << "<input name='A01Y_RETLINK' type='hidden' value='#{tupas_request_params['A01Y_RETLINK']}'/>"
        _form << "<input name='A01Y_CANLINK' type='hidden' value='#{tupas_request_params['A01Y_CANLINK']}'/>"
        _form << "<input name='A01Y_REJLINK' type='hidden' value='#{tupas_request_params['A01Y_REJLINK']}'/>"
        _form << "<input name='A01Y_KEYVERS' type='hidden' value='#{tupas_request_params['A01Y_KEYVERS']}'/>"
        _form << "<input name='A01Y_ALG' type='hidden' value='#{tupas_request_params['A01Y_ALG']}'/>"
        _form << "<input name='A01Y_MAC' type='hidden' value='#{tupas_request_params['A01Y_MAC']}'/>"
        _form << "<input name='SUBMIT' type='submit' value='#{tupas_request_params['name']}' />"
        _form << "</form>"
      end
      _form
    end
  end
end

