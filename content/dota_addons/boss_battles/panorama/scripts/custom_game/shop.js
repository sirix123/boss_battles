"use strict";

// events
// GameEvents.Subscribe( "picking_done", OnPickingDone );
// GameEvents.Subscribe( "player_reconnect", OnPickingDone );
// GameEvents.Subscribe( "player_reconnect", FixUpPortrait );
// GameEvents.Subscribe( "send_product_list", OnPickingDone );
// GameEvents.Subscribe( "open_shop_external", OnServerSendOpenShop );
// GameEvents.Subscribe( "update_shop_product_list", OnServerUpdatePlayerShop );
// GameEvents.Subscribe( "shop_status", OnServerShopStatus );

/* Event Handlers
=========================================================================*/
/* After picking is done spawn the shop button */
let product_list = [];
function OnPickingDone( data ) {

    for (let i = 1; data[i] !== undefined; i++) {
    	let products = [];
        for(let j = 1; data[i]["products"][j] !== undefined; j++)
        {
			products.push(data[i]["products"][j]);
        }
        let heroProductMap = { 
        	hero: data[i]["hero"],
        	products: products
         };
     	product_list.push(heroProductMap);
    }

    //$.Msg("product_list, ",product_list)

}

/* When player presses the buy button server returns a url with their steamid */
function OnServerSendOpenShop( data ) {

    let end_url = "";
    for (let i = 1; data[i] !== undefined; i++) {
        end_url = data[i]; 
    }

    var start_url = "https://";
    //var start_url = "http://";
    $.DispatchEvent("ExternalBrowserGoToURL",  start_url.concat(end_url) ); 
}

/* when the server sends an updated shop list based on purchases change buttons from buy to equip if they have purchased */
let player_purchase_list = [];
function OnServerUpdatePlayerShop( data ) {

    player_purchase_list = [];

    for (let i = 1; data[i] !== undefined; i++) {
    	let products_purchased = [];
        for(let j = 1; data[i][j] !== undefined; j++)
        {
			products_purchased.push(data[i][j]);
        }
        let heroProductMap = {
        	products_purchased: products_purchased
         };
     	player_purchase_list.push(heroProductMap);
    }

    //$.Msg("player_purchase_list ",player_purchase_list)
}

/* if the shop server is down disable the buttona nd close the shop if its open*/
function OnServerShopStatus( data ) {

    if ( data.shop_status == 0 )
    {
        let shopButtonContainer = $("#ShopButtonPanel");
        shopButtonContainer.style.visibility = 'visible';
        shopButtonContainer.RemoveClass("hidden");
        shopButtonContainer.AddClass( "disabled" );
        shopButtonContainer.ClearPanelEvent( 'onactivate' )

        let shopButton = shopButtonContainer.FindChildInLayoutFile("ShopButton");
        shopButton.AddClass( "disabled" );
        shopButton.ClearPanelEvent( 'onactivate' )
    
        let productListContainer = $("#ProductListContainer");
        for (let i = 0; i < productListContainer.GetChildCount(); i++  )
        {
            var child = productListContainer.GetChild(i)
            child.DeleteAsync(0);
        }
        var rootPanelMainShop = $("#ParentShopPanel");
        rootPanelMainShop.SetHasClass("hidden", true);
    }

    if( data.shop_status ==  1)
    {
        let shopButtonContainer = $("#ShopButtonPanel");
        shopButtonContainer.style.visibility = 'visible';
        shopButtonContainer.RemoveClass("hidden");

        let shopButton = shopButtonContainer.FindChildInLayoutFile("ShopButton");
        let shopButtonTxt = shopButtonContainer.FindChildInLayoutFile("ShopButtonLabel");
        shopButtonTxt.RemoveClass( "disabled" );
        shopButton.RemoveClass( "disabled" );

        shopButton.SetPanelEvent( 'onactivate', function () {
            OnShopButtonPressed();
        });
    }
}

/* Button Event Handlers
=========================================================================*/
function OnShopButtonPressed(){

    // disable the shot button
    let shopButtonContainer = $("#ShopButtonPanel");
    let shopButton = shopButtonContainer.FindChildInLayoutFile("ShopButton");
    shopButton.AddClass( "disabled" );
    shopButton.ClearPanelEvent( 'onactivate' )

    var rootPanelMainShop = $("#ParentShopPanel");
    rootPanelMainShop.RemoveClass("hidden");

	let productListContainer = $("#ProductListContainer");

    // load tooltip
    // rootPanelMainShop
    let tooltipLabel = $("#ToolTipInfoContainer")
    let toolTipContainer = $("#ToolTip");
	toolTipContainer.style.visibility = 'collapse';

    tooltipLabel.SetPanelEvent( 'onmouseover', function () {
        toolTipContainer.RemoveClass("hidden");
        toolTipContainer.style.visibility = 'visible';
        var tooltipText = toolTipContainer.FindChildInLayoutFile("ToolTipTxt");
        tooltipText.text = "The shop can take a few minutes to update after loading into the game, to refresh the shop open and close it.";
    });

    tooltipLabel.SetPanelEvent( 'onmouseout', function () {
        toolTipContainer.style.visibility = 'collapse';
    });

    for (let [key, value] of Object.entries(product_list)) {
        for (let i = 0; i < value["products"].length; i++) {

            let productPanel = $.CreatePanel("Panel", productListContainer, value["products"][i]);
            productPanel.BLoadLayoutSnippet("ProductList");

            let buyButton = productPanel.FindChildInLayoutFile("ProductPurchaseButton");
            let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
            buyButton.RemoveClass( "disabled" );
            buyButtonTxt.text = "Buy now!";
            buyButton.SetPanelEvent( 'onactivate', function () {
                OnBuyButtonPressed( buyButton, buyButtonTxt );
            });

            // get appropriate image for the product id provided
            let image_name = GetProductImage(value["products"][i]);
            let heroImage = productPanel.FindChildInLayoutFile("HeroImage");

            let product_name = GetProductTitle(value["products"][i]);
            if( product_name ){
                let nameTxt = productPanel.FindChildInLayoutFile("ProductDisplayTitleTxt");
                nameTxt.text = product_name;
            }

            if( image_name ){
                heroImage.SetImage('file://{images}/heroes/selection/' + image_name + '.png');
                heroImage.style.backgroundImage = 'url("file://{images}/heroes/' + image_name + '.png")';
                heroImage.style.backgroundSize = "100% 100%";
            }
           
            let playerId = Players.GetLocalPlayer()
            let player_hero = Players.GetPlayerSelectedHero( playerId )

            // check the product list against the player purcahse list whenever the shop is loaded, 
            for (let [key2, value2] of Object.entries(player_purchase_list)) { 
                for (let j = 0; j < value2["products_purchased"].length; j++) {
                    if(value2["products_purchased"][j] == value["products"][i])
                    {
                        // show the equip button if theyre the correct hero
                        if( player_hero == value["hero"])
                        {
                            let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                            buyButton.RemoveClass( "disabled" );
                            buyButton.AddClass( "equip" );
                            buyButtonTxt.text = "Equip";
                            buyButton.product = value2["products_purchased"][j];
                            buyButton.SetPanelEvent( 'onactivate', function () {
                                OnEquipButtonPressed( buyButton.product, image_name, buyButton, buyButtonTxt );
                            });

                            //$.Msg("setting button to equip enabled")
                            break;
                        }
                        // disable if not the correct hero
                        else
                        {
                            let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                            buyButton.AddClass( "disabled" );
                            buyButtonTxt.text = "Incorrect hero";
                            buyButton.ClearPanelEvent( 'onactivate' )

                            //$.Msg("setting button to equip disabled")
                            break;
                        }
        
                    }
                    //else show the buy button
                    else
                    {
                        let buyButtonTxt = productPanel.FindChildInLayoutFile("ProductPurchaseButtonTxt");
                        buyButton.RemoveClass( "disabled" );
                        buyButtonTxt.text = "Buy now!";
                        buyButton.SetPanelEvent( 'onactivate', function () {
                            OnBuyButtonPressed( buyButton, buyButtonTxt );
                        });

                        //$.Msg("setting button to buy now enabled")
                    }
                }
            }
        }
	}
}

function OnBuyButtonPressed( buyButton, buyButtonTxt ){

    // disable the button to show something is happening...
    buyButton.AddClass( "disabled" );
    buyButtonTxt.text = "Processing...";
    buyButtonTxt.AddClass( "disabled" );
    buyButton.ClearPanelEvent( 'onactivate' );

    GameEvents.SendCustomGameEventToServer( "player_pressed_buy_button", { } );

}

function OnEquipButtonPressed( product_id, image_name, buyButton, buyButtonTxt ){

    let playerId = Players.GetLocalPlayer()
    let player_hero = Players.GetPlayerSelectedHero( playerId )

    FixUpPortrait()

    // disable the equip button
    buyButton.AddClass( "disabled" );
    buyButtonTxt.text = "Set equipped";
    buyButton.ClearPanelEvent( 'onactivate' )

    GameEvents.SendCustomGameEventToServer( "player_pressed_equip_button", { player_hero, product_id } );
}

function FixUpPortrait(){

    // fix portrait (add a panel on top the existing portrait location)
    var main = $.GetContextPanel().GetParent().GetParent().GetParent();
    var portraitContainer = main.FindChildTraverse('PortraitContainer');
    var portraitHUD = main.FindChildTraverse("portraitHUD");
    portraitHUD.style.opacity = 0;

    let playerId = Players.GetLocalPlayer()
    let player_hero = Players.GetPlayerSelectedHero( playerId )

    // fix up portrait
    //var MovieContainer = $.CreatePanel( "Panel", portraitContainer, "CustomHeroMoviePortrait" )
    //MovieContainer.BLoadLayoutFromString( '<root><Panel><MoviePanel src="s2r://panorama/videos/heroes/' + player_hero + '.webm" repeat="true" autoplay="onload" /></Panel></root>', false, false )
    //MovieContainer.style.width = "160px";
    //MovieContainer.style.height = "203px";
    //MovieContainer.style.boxShadow = "#000000aa 0px 0px 16px 0px";

    var MovieContainer = $.CreatePanelWithProperties("MoviePanel", portraitContainer, "CustomHeroMoviePortrait", { src: 'file://{resources}videos/heroes/' + player_hero + '.webm', repeat: "true",  autoplay: "onload" });

}

function OnShopCloseButtonPressed(){

    let productListContainer = $("#ProductListContainer");

    for (let i = 0; i < productListContainer.GetChildCount(); i++  )
	{
		var child = productListContainer.GetChild(i)
		child.DeleteAsync(0);
	}

    var rootPanelMainShop = $("#ParentShopPanel");
	rootPanelMainShop.SetHasClass("hidden", true);

    let shopButtonContainer = $("#ShopButtonPanel");
    let shopButton = shopButtonContainer.FindChildInLayoutFile("ShopButton");
    shopButton.RemoveClass( "disabled" );
    shopButton.SetPanelEvent( 'onactivate', function () {
        OnShopButtonPressed();
    });
}

/*
=========================================================================*/
function GetProductImage( product_id ){
    if( product_id == "prod_K3nLLJ8Cg5oRRN"){
        return "npc_dota_hero_crystal_maiden_alt1";
    }

    if( product_id == "prod_K3nLHE2IAIKZhx"){
        return "npc_dota_hero_queenofpain_alt1";
    }

    if( product_id == "prod_K3nKsxusCxUqlx"){
        return "npc_dota_hero_lina_alt1";
    }

    if( product_id == "prod_K3nKKvwFuhrkse"){
        return "npc_dota_hero_phantom_assassin_alt1";
    }

    if( product_id == "prod_K3nKIapPT9IwVx"){
        return "npc_dota_hero_juggernaut_alt1";
    }

    if( product_id == "prod_K3nKNer3yuFb1P"){
        return "npc_dota_hero_windrunner_alt1";
    }

    if( product_id == "prod_JhhDN4uB5R7qT4"){
        return "npc_dota_hero_omniknight";
    }
}

/*
=========================================================================*/
function GetProductTitle( product_id ){
    if( product_id == "prod_K3nLLJ8Cg5oRRN"){
        return "Rylai";
    }

    if( product_id == "prod_K3nLHE2IAIKZhx"){
        return "Akasha";
    }

    if( product_id == "prod_K3nKsxusCxUqlx"){
        return "Lina";
    }

    if( product_id == "prod_K3nKKvwFuhrkse"){
        return "Nightblade";
    }

    if( product_id == "prod_K3nKIapPT9IwVx"){
        return "Blademaster";
    }

    if( product_id == "prod_K3nKNer3yuFb1P"){
        return "Windrunner";
    }
}

/* runs when client loads files
=========================================================================*/
(function () {
	var rootPanel = $("#ShopButtonPanel");
	rootPanel.SetHasClass("hidden", true);

    var rootPanelMainShop = $("#ParentShopPanel");
	rootPanelMainShop.SetHasClass("hidden", true);

    var rootTooltip = $("#ToolTip");
	rootTooltip.SetHasClass("hidden", true);
})();

