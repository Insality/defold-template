local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local logger = log.get_logger("iap_mobile")


local Iaps = {}


local function iap_listener(self, transaction, error)
    if error then
        logger:error("Iap listener error", { error = error })
    end
end


function Iaps.init()
    iap.set_listener(iap_listener)
end


function Iaps.buy(iap_ident)
    iap.buy(iap_ident)
end


function Iaps.consume(transaction)

end


function Iaps.fetch_products()
    iap.list(luax.table.list(app.iap_products, "ident"), list_callback)
end


function Iaps.restore()
    iap.restore()
end


return Iaps
