if CosmeticManager == nil then
    CosmeticManager = class({})
end


-- returns the list of purchaseable productrs, calls the webserver API, webserver returns stripe product list
function CosmeticManager:GetProductList()

    local product_player_list = { }
    product_player_list["steam_ID"] = "21312312312312312"

    local product_list = { }
    product_list["PRODUCT_NAME_1"] = true
    product_list["PRODUCT_NAME_2"] = true
    product_list["PRODUCT_NAME_3"] = true

    product_player_list["product_list"] = product_list

    print(dump(json.encode(product_player_list)))

    -- call function from webapi (GetProductList) or something

    return product_player_list
end