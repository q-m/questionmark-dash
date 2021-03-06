require 'open-uri'
require 'json'

SCHEDULER.every '24h', :first_in => 0 do |job|
  open 'https://api-c.thequestionmark.org/api/v1.1/products?per_page=1' do |f|
    result = JSON.parse(f.read)
    send_event('qm-products-total', {current: result['total']})
  end

  open 'https://api-c.thequestionmark.org/api/v1.1/products?per_page=1&scored=1&page=2' do |f|
    result = JSON.parse(f.read)
    send_event('qm-products-with-score', {value: result['total']})
  end

  if ENV['QM_BARCODES_URL']
    open ENV['QM_BARCODES_URL'] do |f|
      result = JSON.parse(f.read)
      send_event('qm-products-barcodes', {current: result['barcodes'].count})
    end
  end
end
