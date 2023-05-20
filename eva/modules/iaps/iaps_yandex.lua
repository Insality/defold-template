local log = require("eva.log")
local app = require("eva.app")
local const = require("eva.const")
local yagames = const.require("yagames.yagames")

local logger = log.get_logger("iap_yandex")

local Iaps = {}


function Iaps.init()
    yagames.payments_init({ signed = true }, function(_, err)
        if err then
            logger:error("Yandex IAP init error", { error = err })
        end
    end)
end


function Iaps.buy(iap_id)
    yagames.payments_purchase({ id = iap_id }, function(_, err, purchase)
        if err then
            logger:error("Yandex IAP buy error", { error = err })
        end
    end)
end


function Iaps.consume(transaction_token)
    yagames.payments_consume_purchase(transaction_token, function()
        logger:error("Yandex consume callback")
    end)
end


function Iaps.fetch_products()
    yagames.payments_get_catalog(function(_, err, catalog)
        if err then
            logger:error("Yandex IAP fetch error", { error = err })
        end
        logger:info("Fetch IAP products", { catalog = catalog })

        for index = 1, #catalog do
            local product = catalog[index]

            local iap_info = app.iap_products[product.id]
            iap_info.is_available = true
            iap_info.currency_code = product.priceCurrencyCode
            iap_info.title = product.title
            iap_info.description = product.description
            iap_info.price_string = product.price
            iap_info.price = product.priceValue
        end
    end)
end


function Iaps.restore()
    yagames.payments_get_purchases(function(_, err, purchases)
        if err then
            logger:error("Yandex IAP restore error", { error = err })
        end
        logger:info("Restore purchases", { purchases = purchases })
    end)
end


return Iaps
