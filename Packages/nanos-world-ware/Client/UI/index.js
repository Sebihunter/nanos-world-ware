var setText = '';

Events.on("UpdateText", function(myText) {
	$('#ware_text').slideDown("fast");
	setText = myText;
    // Using JQuery, overrides the HTML content of the SPAN with the new health value7
    $('#ware_text').slideUp("fast", function(){
		  $('#ware_text').html(setText);
		  $('#ware_text').slideDown("fast");
	});
});

 
// Register for UpdateWeaponAmmo custom event (from Lua)
Events.on("UpdateWeaponAmmo", function(enable, clip, bag) {
    if (enable)
        $("#weapon_ammo_container").show();
    else
        $("#weapon_ammo_container").hide();

    // Using JQuery, overrides the HTML content of these SPANs with the new Ammo values
    $("#weapon_ammo_clip").html(clip);
    $("#weapon_ammo_bag").html("/ " + bag);
});

// Register for UpdateHealth custom event (from Lua)
Events.on("UpdateHealth", function(health) {
    // Using JQuery, overrides the HTML content of the SPAN with the new health value
    $("#health_current").html(health);

    // Bonus: make the background red when health below 25
    //if (health <= 25)
        //$("#health_container").css("background-image", "linear-gradient(to left, #0000, #d00c)");
   // else
        //$("#health_container").css("background-image", "linear-gradient(to left, #00000000, #00000080)");
	//#health_current
});

Events.on("UpdatePosition", function(x,y,z) {
    // Using JQuery, overrides the HTML content of the SPAN with the new health value7
    $("#position_current").html(" "+x+" / "+y+" / "+z);
});

Events.on("UpdateList", function(wRound,aRound,perc,winners,winstring,losers,losestring) {
    $("#winstreak_current").html(wRound+"/"+aRound+"<br>"+perc+"%");
	$("#loosers_current").html("("+losers+") Losers");
	$("#winners_current").html("Winners ("+winners+")");
	$("#loosers_list").html(losestring);
	$("#winners_list").html(winstring);
});



// Register for UpdateHealth custom event (from Lua)
Events.on("SetText", function(health) {
    // Using JQuery, overrides the HTML content of the SPAN with the new health value
    $("#health_current").html(health);

    // Bonus: make the background red when health below 25
    if (health <= 25)
        $("#health_container").css("background-image", "linear-gradient(to left, #0000, #d00c)");
    else
        $("#health_container").css("background-image", "linear-gradient(to left, #00000000, #00000080)");
})