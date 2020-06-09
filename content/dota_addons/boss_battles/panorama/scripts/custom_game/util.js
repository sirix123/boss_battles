
function Clamp(num, min, max) {
    return num < min ? min : num > max ? max : num;
}

function SubscribeToNetTableKey(table, key, loadNow, callback){
    var listener = CustomNetTables.SubscribeNetTableListener(table, function(table, tableKey, data){
        if (key == tableKey){
            if (!data) {
                return;
            }

            callback(data, false);
        }
    });

    if (loadNow){
        var data = CustomNetTables.GetTableValue(table, key);

        if (data) {
            callback(data, true);
        }
    }

    return listener;
}