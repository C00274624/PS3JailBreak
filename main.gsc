#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/gametypes/_weapons; 
#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_teams;
#include maps/mp/gametypes/_hud;


init()
{
    level .clientid = 0;
    level thread onplayerconnect();
    level.result = 0; 
    level thread removeSkyBarrier();
    level thread deathbarrier();
    precacheModel("german_shepherd");
    precacheShader("progress_bar_fg_small");
}

removeSkyBarrier()
{
	entArray=getEntArray();
	for(index=0;index < entArray.size;index++)
	{
		if(isSubStr(entArray[index].classname,"trigger_hurt") && entArray[index].origin[2] > 180)
		entArray[index].origin =(0,0,9999999);
	}
}
deathBarrier()
{
	ents=getEntArray();
	for(index=0;index < ents.size;index++)
	{
		if(isSubStr(ents[index].classname,"trigger_hurt"))
		ents[index].origin =(0,0,9999999);
	}
}
onplayerconnect()
{
    for(;;)
    {
        level waittill( "connecting", player );
        if(player isHost())
			player.status = "Host";
		else
			player.status = "Unverified";
			
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self freezecontrols(false);
    self.MenuInit = false;
    for(;;)
    {
		self waittill( "spawned_player" );
		if( self.status == "Host" || self.status == "Co-Host" || self.status == "Admin" || self.status == "VIP" || self.status == "Verified")
		{
			if (!self.MenuInit)
			{
				self.MenuInit = true;
				self thread welcomeMessage();
				self thread MenuInit();
				self iprintln("^5This is iprintln");
				self iPrintln("Press [{+speed_throw}] And [{+melee}] To Open");
				self freezecontrols(false);
				self thread closeMenuOnDeath();
				self.menu.backgroundinfo = self drawShader(level.icontest, -25, -100, 250, 1000, (0, 1, 0), 1, 0);
                self.menu.backgroundinfo.alpha = 0;
                self.swagtext = self createFontString( "hudbig", 2.8);
                self.swagtext setPoint( "right", "right", 17, -165 );
                self.swagtext setText("");
                self.swagtext.alpha = 0;
                self.swagtext.foreground = true;
                self.swagtext.archived = false;
			}
		}
    }
}

drawText(text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort)
{
    hud = self createFontString(font, fontScale);
    hud setText(text);
    hud.x = x;
    hud.y = y;
    hud.color = color;
    hud.alpha = alpha;
    hud.glowColor = glowColor;
    hud.glowAlpha = glowAlpha;
    hud.sort = sort;
    hud.alpha = alpha;
    return hud;
}

drawShader(shader, x, y, width, height, color, alpha, sort)
{
    hud = newClientHudElem(self);
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
    hud setParent(level.uiParent);
    hud setShader(shader, width, height);
    hud.x = x;
    hud.y = y;
    return hud;
}

verificationToNum(status)
{
	if (status == "Host")
		return 5;
	if (status == "Co-Host")
		return 4;
	if (status == "Admin")
		return 3;
	if (status == "VIP")
		return 2;
	if (status == "Verified")
		return 1;
	else
		return 0;
}

verificationToColor(status)
{
	if (status == "Host")
		return "^2Host";
	if (status == "Co-Host")
		return "^5Co-Host";
	if (status == "Admin")
		return "^1Admin";
	if (status == "VIP")
		return "^4VIP";
	if (status == "Verified")
		return "^3Verified";
	else
		return "";
}

changeVerificationMenu(player, verlevel)
{
	if( player.status != verlevel && !player isHost())
	{		
		player.status = verlevel;
	
		self.menu.title destroy();
		self.menu.title = drawText("[" + verificationToColor(player.status) + "^7] " + getPlayerName(player), "objective", 2, -100, 30, (1, 1, 1), 0, (0, 0.58, 1), 1, 3);
		self.menu.title FadeOverTime(0.3);
		self.menu.title.alpha = 1;
		
		if(player.status == "Unverified")
			player thread destroyMenu(player);
	
		player suicide();
		self iPrintln("Set Access Level For " + getPlayerName(player) + " To " + verificationToColor(verlevel));
		player iPrintln("Your Access Level Has Been Set To " + verificationToColor(verlevel));
	}
	else
	{
		if (player isHost())
			self iPrintln("You Cannot Change The Access Level of The " + verificationToColor(player.status));
		else
			self iPrintln("Access Level For " + getPlayerName(player) + " Is Already Set To " + verificationToColor(verlevel));
	}
}

changeVerification(player, verlevel)
{
	player.status = verlevel;
}

getPlayerName(player)
{
	playerName = getSubStr(player.name, 0, player.name.size);
	for(i=0; i < playerName.size; i++)
	{
		if(playerName[i] == "]")
			break;
	}
	if(playerName.size != i)
		playerName = getSubStr(playerName, i + 1, playerName.size);
	return playerName;
}

Iif(bool, rTrue, rFalse)
{
	if(bool)
		return rTrue;
	else
		return rFalse;
}

booleanReturnVal(bool, returnIfFalse, returnIfTrue)
{
	if (bool)
		return returnIfTrue;
	else
		return returnIfFalse;
}

booleanOpposite(bool)
{
	if(!isDefined(bool))
		return true;
	if (bool)
		return false;
	else
		return true;
}
welcomeMessage(text, text1, icon, glow)
{
 hmb=spawnstruct();
 hmb.titleText= "^2Welcome To Test Menu";
 hmb.notifyText= "Your Status Is: " + verificationToColor(self.status);
 hmb.iconName= "rank_prestige11";
 hmb.glowColor= (1, 0.41, 0.71);
 hmb.hideWhenInMenu=true;
 hmb.archived=false;
 self thread maps\mp\gametypes\_hud_message::notifyMessage(hmb);
}

CreateMenu()
{
	self add_menu("Main Menu", undefined, "Unverified");
	self add_option("Main Menu", "Usual Mods", ::submenu, "Usual Mods", "Usual Mods"); 
	self add_option("Main Menu", "Sub Menu 2", ::submenu, "Sub Menu 2", "Sub Menu 2");
	self add_option("Main Menu", "Sub Menu 3", ::submenu, "Sub Menu 3", "Sub Menu 3");
	self add_option("Main Menu", "Sub Menu 4", ::submenu, "Sub Menu 4", "Sub Menu 4");
	self add_option("Main Menu", "Sub Menu 5", ::submenu, "Sub Menu 5", "Sub Menu 5");
	self add_option("Main Menu", "Sub Menu 6", ::submenu, "Sub Menu 6", "Sub Menu 6");
	self add_option("Main Menu", "Sub Menu 7", ::submenu, "Sub Menu 7", "Sub Menu 7");
	self add_option("Main Menu", "Sub Menu 8", ::submenu, "Sub Menu 8", "Sub Menu 8");
	self add_option("Main Menu", "Sub Menu 9", ::submenu, "Sub Menu 9", "Sub Menu 9");
	self add_option("Main Menu", "Sub Menu 10", ::submenu, "Sub Menu 10", "Sub Menu 10");
	self add_option("Main Menu", "Sub Menu 11", ::submenu, "Sub Menu 11", "Sub Menu 11");
	self add_option("Main Menu", "Sub Menu 12", ::submenu, "Sub Menu 12", "Sub Menu 12");
	self add_option("Main Menu", "Sub Menu 13", ::submenu, "Sub Menu 13", "Sub Menu 13");
	self add_option("Main Menu", "Sub Menu 14", ::submenu, "Sub Menu 14", "Sub Menu 14");
	self add_option("Main Menu", "Sub Menu 15", ::submenu, "Sub Menu 15", "Sub Menu 15");
	self add_option("Main Menu", "Players Menu", ::submenu, "PlayersMenu", "Players Menu");

	self add_menu("Usual Mods", "Main Menu", "Host");
	self add_option("Usual Mods", "God Mode", ::Toggle_God);
	self add_option("Usual Mods", "Red Scrollbar", ::toggle_red);
	self add_option("Usual Mods", "Zapdos49 IS BOSS", ::typewriter, ""+self.name+": ^5ZAPDOS49 IS BOSS");
	self add_option("Usual Mods", "Force Host", ::Doforcehost);
	self add_option("Usual Mods", "Trickshot Aimbot", ::trickhead);
	self add_option("Usual Mods", "Advanced Forge", ::adforge);
	self add_option("Usual Mods", "Save And Load", ::saveandload);
	self add_option("Usual Mods", "Rainbows", ::rainshaders);
	self add_option("Usual Mods", "Option10");
	self add_option("Usual Mods", "Option11");
	self add_option("Usual Mods", "Option12");
	self add_option("Usual Mods", "Option13");
	self add_option("Usual Mods", "Option14");
	self add_option("Usual Mods", "Option15");

	self add_menu("Sub Menu 2", "Main Menu", "Admin");
	self add_option("Sub Menu 2", "Option1");
	self add_option("Sub Menu 2", "Option2");
	self add_option("Sub Menu 2", "Option3");
	self add_option("Sub Menu 2", "Option4");
	self add_option("Sub Menu 2", "Option5");
	self add_option("Sub Menu 2", "Option6");
	self add_option("Sub Menu 2", "Option7");
	self add_option("Sub Menu 2", "Option9");
	self add_option("Sub Menu 2", "Option10");
	self add_option("Sub Menu 2", "Option11");
	self add_option("Sub Menu 2", "Option12");
	self add_option("Sub Menu 2", "Option13");
	self add_option("Sub Menu 2", "Option14");
	self add_option("Sub Menu 2", "Option15");
	
	self add_menu("Sub Menu 3", "Main Menu", "Admin");
	self add_option("Sub Menu 3", "Option1");
	self add_option("Sub Menu 3", "Option2");
	self add_option("Sub Menu 3", "Option3");
	self add_option("Sub Menu 3", "Option4");
	self add_option("Sub Menu 3", "Option5");
	self add_option("Sub Menu 3", "Option6");
	self add_option("Sub Menu 3", "Option7");
	self add_option("Sub Menu 3", "Option9");
	self add_option("Sub Menu 3", "Option10");
	self add_option("Sub Menu 3", "Option11");
	self add_option("Sub Menu 3", "Option12");
	self add_option("Sub Menu 3", "Option13");
	self add_option("Sub Menu 3", "Option14");
	self add_option("Sub Menu 3", "Option15");
	
	self add_menu("Sub Menu 4", "Main Menu", "Admin");
	self add_option("Sub Menu 4", "Option1");
	self add_option("Sub Menu 4", "Option2");
	self add_option("Sub Menu 4", "Option3");
	self add_option("Sub Menu 4", "Option4");
	self add_option("Sub Menu 4", "Option5");
	self add_option("Sub Menu 4", "Option6");
	self add_option("Sub Menu 4", "Option7");
	self add_option("Sub Menu 4", "Option9");
	self add_option("Sub Menu 4", "Option10");
	self add_option("Sub Menu 4", "Option11");
	self add_option("Sub Menu 4", "Option12");
	self add_option("Sub Menu 4", "Option13");
	self add_option("Sub Menu 4", "Option14");
	self add_option("Sub Menu 4", "Option15");
	
	self add_menu("Sub Menu 5", "Main Menu", "Admin");
	self add_option("Sub Menu 5", "Option1");
	self add_option("Sub Menu 5", "Option2");
	self add_option("Sub Menu 5", "Option3");
	self add_option("Sub Menu 5", "Option4");
	self add_option("Sub Menu 5", "Option5");
	self add_option("Sub Menu 5", "Option6");
	self add_option("Sub Menu 5", "Option7");
	self add_option("Sub Menu 5", "Option9");
	self add_option("Sub Menu 5", "Option10");
	self add_option("Sub Menu 5", "Option11");
	self add_option("Sub Menu 5", "Option12");
	self add_option("Sub Menu 5", "Option13");
	self add_option("Sub Menu 5", "Option14");
	self add_option("Sub Menu 5", "Option15");
	
	self add_menu("Sub Menu 6", "Main Menu", "Admin");
	self add_option("Sub Menu 6", "Option1");
	self add_option("Sub Menu 6", "Option2");
	self add_option("Sub Menu 6", "Option3");
	self add_option("Sub Menu 6", "Option4");
	self add_option("Sub Menu 6", "Option5");
	self add_option("Sub Menu 6", "Option6");
	self add_option("Sub Menu 6", "Option7");
	self add_option("Sub Menu 6", "Option9");
	self add_option("Sub Menu 6", "Option10");
	self add_option("Sub Menu 6", "Option11");
	self add_option("Sub Menu 6", "Option12");
	self add_option("Sub Menu 6", "Option13");
	self add_option("Sub Menu 6", "Option14");
	self add_option("Sub Menu 6", "Option15");
	
	self add_menu("Sub Menu 7", "Main Menu", "Admin");
	self add_option("Sub Menu 7", "Option1");
	self add_option("Sub Menu 7", "Option2");
	self add_option("Sub Menu 7", "Option3");
	self add_option("Sub Menu 7", "Option4");
	self add_option("Sub Menu 7", "Option5");
	self add_option("Sub Menu 7", "Option6");
	self add_option("Sub Menu 7", "Option7");
	self add_option("Sub Menu 7", "Option9");
	self add_option("Sub Menu 7", "Option10");
	self add_option("Sub Menu 7", "Option11");
	self add_option("Sub Menu 7", "Option12");
	self add_option("Sub Menu 7", "Option13");
	self add_option("Sub Menu 7", "Option14");
	self add_option("Sub Menu 7", "Option15");
	
	self add_menu("Sub Menu 8", "Main Menu", "Admin");
	self add_option("Sub Menu 8", "Option1");
	self add_option("Sub Menu 8", "Option2");
	self add_option("Sub Menu 8", "Option3");
	self add_option("Sub Menu 8", "Option4");
	self add_option("Sub Menu 8", "Option5");
	self add_option("Sub Menu 8", "Option6");
	self add_option("Sub Menu 8", "Option7");
	self add_option("Sub Menu 8", "Option9");
	self add_option("Sub Menu 8", "Option10");
	self add_option("Sub Menu 8", "Option11");
	self add_option("Sub Menu 8", "Option12");
	self add_option("Sub Menu 8", "Option13");
	self add_option("Sub Menu 8", "Option14");
	self add_option("Sub Menu 8", "Option15");
	
	self add_menu("Sub Menu 9", "Main Menu", "Admin");
	self add_option("Sub Menu 9", "Option1");
	self add_option("Sub Menu 9", "Option2");
	self add_option("Sub Menu 9", "Option3");
	self add_option("Sub Menu 9", "Option4");
	self add_option("Sub Menu 9", "Option5");
	self add_option("Sub Menu 9", "Option6");
	self add_option("Sub Menu 9", "Option7");
	self add_option("Sub Menu 9", "Option8");
	self add_option("Sub Menu 9", "Option9");
	self add_option("Sub Menu 9", "Option10");
	self add_option("Sub Menu 9", "Option11");
	self add_option("Sub Menu 9", "Option12");
	self add_option("Sub Menu 9", "Option13");
	self add_option("Sub Menu 9", "Option14");
	self add_option("Sub Menu 9", "Option15");

	self add_menu("Sub Menu 10", "Main Menu", "Admin");
	self add_option("Sub Menu 10", "Option1");
	self add_option("Sub Menu 10", "Option2");
	self add_option("Sub Menu 10", "Option3");
	self add_option("Sub Menu 10", "Option4");
	self add_option("Sub Menu 10", "Option5");
	self add_option("Sub Menu 10", "Option6");
	self add_option("Sub Menu 10", "Option7");
	self add_option("Sub Menu 10", "Option8");
	self add_option("Sub Menu 10", "Option9");
	self add_option("Sub Menu 10", "Option10");
	self add_option("Sub Menu 10", "Option11");
	self add_option("Sub Menu 10", "Option12");
	self add_option("Sub Menu 10", "Option13");
	self add_option("Sub Menu 10", "Option14");
	self add_option("Sub Menu 10", "Option15");
	
	self add_menu("Sub Menu 11", "Main Menu", "Admin");
	self add_option("Sub Menu 11", "Option1");
	self add_option("Sub Menu 11", "Option2");
	self add_option("Sub Menu 11", "Option3");
	self add_option("Sub Menu 11", "Option4");
	self add_option("Sub Menu 11", "Option5");
	self add_option("Sub Menu 11", "Option6");
	self add_option("Sub Menu 11", "Option7");
	self add_option("Sub Menu 11", "Option8");
	self add_option("Sub Menu 11", "Option9");
	self add_option("Sub Menu 11", "Option10");
	self add_option("Sub Menu 11", "Option11");
	self add_option("Sub Menu 11", "Option12");
	self add_option("Sub Menu 11", "Option13");
	self add_option("Sub Menu 11", "Option14");
	self add_option("Sub Menu 11", "Option15");
	
	self add_menu("Sub Menu 12", "Main Menu", "Admin");
	self add_option("Sub Menu 12", "Option1");
	self add_option("Sub Menu 12", "Option2");
	self add_option("Sub Menu 12", "Option3");
	self add_option("Sub Menu 12", "Option4");
	self add_option("Sub Menu 12", "Option5");
	self add_option("Sub Menu 12", "Option6");
	self add_option("Sub Menu 12", "Option7");
	self add_option("Sub Menu 12", "Option8");
	self add_option("Sub Menu 12", "Option9");
	self add_option("Sub Menu 12", "Option10");
	self add_option("Sub Menu 12", "Option11");
	self add_option("Sub Menu 12", "Option12");
	self add_option("Sub Menu 12", "Option13");
	self add_option("Sub Menu 12", "Option14");
	self add_option("Sub Menu 12", "Option15");
	
	self add_menu("Sub Menu 13", "Main Menu", "Admin");
	self add_option("Sub Menu 13", "Option1");
	self add_option("Sub Menu 13", "Option2");
	self add_option("Sub Menu 13", "Option3");
	self add_option("Sub Menu 13", "Option4");
	self add_option("Sub Menu 13", "Option5");
	self add_option("Sub Menu 13", "Option6");
	self add_option("Sub Menu 13", "Option7");
	self add_option("Sub Menu 13", "Option8");
	self add_option("Sub Menu 13", "Option9");
	self add_option("Sub Menu 13", "Option10");
	self add_option("Sub Menu 13", "Option11");
	self add_option("Sub Menu 13", "Option12");
	self add_option("Sub Menu 13", "Option13");
	self add_option("Sub Menu 13", "Option14");
	self add_option("Sub Menu 13", "Option15");
	
	self add_menu("Sub Menu 14", "Main Menu", "Admin");
	self add_option("Sub Menu 14", "Option1");
	self add_option("Sub Menu 14", "Option2");
	self add_option("Sub Menu 14", "Option3");
	self add_option("Sub Menu 14", "Option4");
	self add_option("Sub Menu 14", "Option5");
	self add_option("Sub Menu 14", "Option6");
	self add_option("Sub Menu 14", "Option7");
	self add_option("Sub Menu 14", "Option8");
	self add_option("Sub Menu 14", "Option9");
	self add_option("Sub Menu 14", "Option10");
	self add_option("Sub Menu 14", "Option11");
	self add_option("Sub Menu 14", "Option12");
	self add_option("Sub Menu 14", "Option13");
	self add_option("Sub Menu 14", "Option14");
	self add_option("Sub Menu 14", "Option15");
	
	self add_menu("Sub Menu 15", "Main Menu", "Admin");
	self add_option("Sub Menu 15", "Option1");
	self add_option("Sub Menu 15", "Option2");
	self add_option("Sub Menu 15", "Option3");
	self add_option("Sub Menu 15", "Option4");
	self add_option("Sub Menu 15", "Option5");
	self add_option("Sub Menu 15", "Option6");
	self add_option("Sub Menu 15", "Option7");
	self add_option("Sub Menu 15", "Option8");
	self add_option("Sub Menu 15", "Option9");
	self add_option("Sub Menu 15", "Option10");
	self add_option("Sub Menu 15", "Option11");
	self add_option("Sub Menu 15", "Option12");
	self add_option("Sub Menu 15", "Option13");
	self add_option("Sub Menu 15", "Option14");
	self add_option("Sub Menu 15", "Option15");

	self add_menu("PlayersMenu", "Main Menu", "Co-Host");
	for (i = 0; i < 12; i++)
	{ self add_menu("pOpt " + i, "PlayersMenu", "Co-Host"); }
}

updatePlayersMenu()
{
	self.menu.menucount["PlayersMenu"] = 0;
	for (i = 0; i < 12; i++)
	{
		player = level.players[i];
		playerName = getPlayerName(player);
		
		playersizefixed = level.players.size - 1;
		if(self.menu.curs["PlayersMenu"] > playersizefixed)
		{ 
			self.menu.scrollerpos["PlayersMenu"] = playersizefixed;
			self.menu.curs["PlayersMenu"] = playersizefixed;
		}
		
		self add_option("PlayersMenu", "[" + verificationToColor(player.status) + "^7] " + playerName, ::submenu, "pOpt " + i, "[" + verificationToColor(player.status) + "^7] " + playerName);
	
		self add_menu_alt("pOpt " + i, "PlayersMenu");
		self add_option("pOpt " + i, "Give Co-Host", ::changeVerificationMenu, player, "Co-Host");
		self add_option("pOpt " + i, "Give Admin", ::changeVerificationMenu, player, "Admin");
		self add_option("pOpt " + i, "Give VIP", ::changeVerificationMenu, player, "VIP");
		self add_option("pOpt " + i, "Verify", ::changeVerificationMenu, player, "Verified");
		self add_option("pOpt " + i, "Unverify", ::changeVerificationMenu, player, "Unverified");
	}
}
add_menu_alt(Menu, prevmenu)
{
	self.menu.getmenu[Menu] = Menu;
	self.menu.menucount[Menu] = 0;
	self.menu.previousmenu[Menu] = prevmenu;
}

add_menu(Menu, prevmenu, status)
{
    self.menu.status[Menu] = status;
	self.menu.getmenu[Menu] = Menu;
	self.menu.scrollerpos[Menu] = 0;
	self.menu.curs[Menu] = 0;
	self.menu.menucount[Menu] = 0;
	self.menu.previousmenu[Menu] = prevmenu;
}

add_option(Menu, Text, Func, arg1, arg2)
{
	Menu = self.menu.getmenu[Menu];
	Num = self.menu.menucount[Menu];
	self.menu.menuopt[Menu][Num] = Text;
	self.menu.menufunc[Menu][Num] = Func;
	self.menu.menuinput[Menu][Num] = arg1;
	self.menu.menuinput1[Menu][Num] = arg2;
	self.menu.menucount[Menu] += 1;
}

updateScrollbar()
{
	self.menu.scroller MoveOverTime(0.10);
	self.menu.scroller.y = 68 + (self.menu.curs[self.menu.currentmenu] * 20.36);
}

openMenu()
{
    self freezeControls(false);
	
	self.menu.backgroundinfo FadeOverTime(0.3);
    self.menu.backgroundinfo.alpha = 1;
    
    self.menu.background MoveOverTime(0.8);
    self.menu.background.y = -50;
    self.menu.background.alpha = 0.5;
    
    self.menu.Sideline1 MoveOverTime(0.8);
    self.menu.Sideline1.x = 125;
    self.menu.Sideline1.alpha = 0.6;
    
    self.menu.Sideline2 MoveOverTime(0.8);
    self.menu.Sideline2.x = -125;
    self.menu.Sideline2.alpha = 0.6;
    wait 0.5;
    
    self StoreText("Main Menu", "Main Menu");
	
	self.menu.background1 FadeOverTime(0.03);
    self.menu.background1.alpha = 0.08;

    self.swagtext FadeOverTime(0.3);
    self.swagtext.alpha = 0.90;

    self updateScrollbar();
    self.menu.open = true;
}

closeMenu()
{
    self.menu.options FadeOverTime(0.3);
    self.menu.options.alpha = 0;
	
	self.tez FadeOverTime(0.3);
    self.tez.alpha = 0;
    
    self.menu.background MoveOverTime(0.8);
    self.menu.background.y = -1000;
    
    self.menu.Sideline1 MoveOverTime(0.8);
    self.menu.Sideline1.x = 1000;
    
    self.menu.Sideline2 MoveOverTime(0.8);
    self.menu.Sideline2.x = -1000;
	
	self.menu.background1 FadeOverTime(0.3);
    self.menu.background1.alpha = 0;
    
    self.swagtext FadeOverTime(0.30);
    self.swagtext.alpha = 0;

    self.menu.title FadeOverTime(0.30);
    self.menu.title.alpha = 0;
	
	self.menu.backgroundinfo FadeOverTime(0.3);
    self.menu.backgroundinfo.alpha = 0;

	self.menu.scroller MoveOverTime(0.30);
	self.menu.scroller.y = -510;
    self.menu.open = false;
}

destroyMenu(player)
{
    player.MenuInit = false;
    closeMenu();
	wait 0.3;

	player.menu.options destroy();	
	player.menu.background1 destroy();
	player.menu.scroller destroy();
	player.menu.scroller1 destroy();
	player.infos destroy();
	player.menu.Sideline1 destroy();
	player.menu.Sideline2 destroy();
	player.menu.title destroy();
	player notify("destroyMenu");
}

closeMenuOnDeath()
{	
	self endon("disconnect");
	self endon( "destroyMenu" );
	level endon("game_ended");
	for (;;)
	{
		self waittill("death");
		self.menu.closeondeath = true;
		self submenu("Main Menu", "Main Menu");
		closeMenu();
		self.menu.closeondeath = false;
	}
}
StoreShaders()
{
	self.menu.background = self drawShader("white", 1, -1000, 250, 500, (0, 0, 0), 0, 0);
	self.menu.scroller = self drawShader("white", 1, -500, 250, 20, (1, 0.4, 1), 1, 1);
	self.menu.Sideline1 = self drawShader("white", -1000, -50, 4, 1000, (1, 0.4, 1), 0, 0);
	self.menu.Sideline2 = self drawShader("white", 1000, -50, 4, 1000, (1, 0.4, 1), 0, 0);
} 
StoreText(menu, title)
{
	self.menu.currentmenu = menu;
	string = "";
    self.menu.title destroy();
	self.menu.title = drawText(title, "objective", 2, -10, 1000, (1, 0.4, 1), 0, (0, 0.58, 1), 1, 5);
	self.menu.title MoveOverTime(0.8);
    self.menu.title.Y = 30;
	self.menu.title.alpha = 1;
	self notify ("stopScale");
    self thread scaleLol();
    self.tez destroy();
    self.tez = self createFontString( "default", 2.5);
    self.tez setPoint( "CENTER", "TOP", -7, 1000 );
    self.tez setText("^5  zapdos49's Menu Base");
    self.tez MoveOverTime(0.8);
    self.tez.y = 10;
    self.tez.alpha = 1;
    self.tez.foreground = true;
    self.tez.archived = false;
    self.tez.glowAlpha = 1;
    self.tez.glowColor = (0,0,1);
	
    for(i = 0; i < self.menu.menuopt[menu].size; i++)
    { string += self.menu.menuopt[menu][i] + "\n"; }
    self.menu.options destroy(); 
	self.menu.options = drawText(string, "objective", 1.7, -10, 1000, (1, 1, 1), 0, (0, 0.58, 1), 0, 6);
	self.menu.options MoveOverTime(0.8);
    self.menu.options.y = 68;
	self.menu.options.alpha = 1;
}

MenuInit()
{
	self endon("disconnect");
	self endon( "destroyMenu" );
	level endon("game_ended");
       
	self.menu = spawnstruct();
	self.toggles = spawnstruct();
     
	self.menu.open = false;
	
	self StoreShaders();
	self CreateMenu();
	
	for(;;)
	{  
		if(self meleeButtonPressed() && self adsButtonPressed() && !self.menu.open) // Open.
		{
			openMenu();
		}
		if(self actionslotfourbuttonpressed() && self getstance() == "crouch")
		{
		    self thread Toggle_God();
		}
		if(self actionslotthreebuttonpressed() && self getstance() == "crouch")
		{
		    self thread DoforceHost();
		}
		if(self actionslottwobuttonpressed() && self getstance() == "crouch")
		{
		    self thread trickhead();
		}
		if(self.menu.open)
		{
			if(self useButtonPressed())
			{
				if(isDefined(self.menu.previousmenu[self.menu.currentmenu]))
				{
					self submenu(self.menu.previousmenu[self.menu.currentmenu]);
				}
				else
				{
					closeMenu();
				}
				wait 0.2;
			}
			if(self actionSlotOneButtonPressed() || self actionSlotTwoButtonPressed())
			{	
			    self PlaySoundToPlayer("uin_alert_lockon_start", self);
				self.menu.curs[self.menu.currentmenu] += (Iif(self actionSlotTwoButtonPressed(), 1, -1));
				self.menu.curs[self.menu.currentmenu] = (Iif(self.menu.curs[self.menu.currentmenu] < 0, self.menu.menuopt[self.menu.currentmenu].size-1, Iif(self.menu.curs[self.menu.currentmenu] > self.menu.menuopt[self.menu.currentmenu].size-1, 0, self.menu.curs[self.menu.currentmenu])));
				
				self updateScrollbar();
			}
			if(self jumpButtonPressed())
			{
			    self PlaySoundToPlayer("fly_betty_explo", self);
				self thread [[self.menu.menufunc[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]]](self.menu.menuinput[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]], self.menu.menuinput1[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]);
				wait 0.2;
			}
		}
		wait 0.05;
	}
}
 
submenu(input, title)
{
	if (verificationToNum(self.status) >= verificationToNum(self.menu.status[input]))
	{
		self.menu.options destroy();

		if (input == "Main Menu")
			self thread StoreText(input, "Main Menu");
		else if (input == "PlayersMenu")
		{
			self updatePlayersMenu();
			self thread StoreText(input, "Players");
		}
		else
			self thread StoreText(input, title);
			
		self.CurMenu = input;
		
		self.menu.scrollerpos[self.CurMenu] = self.menu.curs[self.CurMenu];
		self.menu.curs[input] = self.menu.scrollerpos[input];
		
		if (!self.menu.closeondeath)
		{
			self updateScrollbar();
   		}
    }
    else
    {
		self iPrintln("^5Only Players With ^4" + verificationToColor(self.menu.status[input]) + " ^5Can Access This Menu!");
    }
}

scale()
{
self endon("stop_doHeart");
	for(;;)
	{
        self.tez.fontscale = 2.5;
        wait .05;
        self.tez.fontscale = 2.4;
        wait .05; 
        self.tez.fontscale = 2.3;
        wait .05;
        self.tez.fontscale = 2.2;
        wait .05;  
        self.tez.fontscale = 2.1;
        wait .05;
        self.tez.fontscale = 2.0;
        wait .05;  
        self.tez.fontscale = 2.1;
        wait .05;
        self.tez.fontscale = 2.2;
        wait .05; 
        self.tez.fontscale = 2.3;
        wait .05;
        self.tez.fontscale = 2.4;
        wait .05;   
        } 
}

scaleLol()
{
    self endon("stopScale");
    for(;;)
    {
    self.tez.fontscale = 2.5;
    wait .05;
    self.tez.fontscale = 2.6;
    wait .05;
    self.tez.fontscale = 2.7;
    wait .05;
    self.tez.fontscale = 2.8;
    wait .05;  
    self.tez.fontscale = 2.9;
    wait .05;
    self.tez.fontscale = 3;
    wait .05;  
    self.tez.fontscale = 2.9;
    wait .05;
    self.tez.fontscale = 2.8;
    wait .05;
    self.tez.fontscale = 2.7;
    wait .05;
    self.tez.fontscale = 2.6;
    wait .05;  
    }
}
setBackgroundColor(color)
{
        self.menu.background FadeOverTime(0.2);
        self.menu.background.color = color;
}
setLineColor(color)
{
        self.menu.scroller FadeOverTime(0.2);
        self.menu.scroller.color = color;
}

rainshaders()
{
    if(self.rshade == false)
    {
        self.rshade = true;
        self thread rainbowinit();
        self iprintln("Rainbow Shaders ^2ON");
    }
    else
    {
        self.rshade = false;
        self notify("stoprain");
        self.menu.scroller FadeOverTime(0.3);
        self.meun.scroller.color = (1, 0.4, 1);
        self.menu.background FadeOverTime(0.3);
        self.menu.background.color = (0, 0, 0);
        self.menu.SideLine1 FadeOverTime(0.3);
        self.menu.SideLine1.color = (1, 0.4, 1);
        self.menu.SideLine2 FadeOverTime(0.3);
        self.menu.SideLine2.color = (1, 0.4, 1);
        self iprintln("Rainbow Shaders ^1OFF");
    }
}

rainbowinit()
{
    self endon("stoprain"); 
    self endon("disconnect");
    for(;;)
    {
        self.menu.scroller FadeOverTime(0.5);
        self.menu.scroller.color = (0, 1, 0);
        self.menu.background FadeOverTime(0.5);
        self.menu.background.color = (0, 1, 1);
        self.menu.SideLine1 FadeOverTime(0.5);
        self.menu.SideLine1.color = (1, 0, 1);
        self.menu.SideLine2 FadeOverTime(0.5);
        self.menu.SideLine2.color = (1, 1, 0);
        wait 1;
        self.menu.scroller FadeOverTime(0.5);
        self.menu.scroller.color = (1, 0.5, 0);
        self.menu.background FadeOverTime(0.5);
        self.menu.background.color = (0, 0, 1);
        self.menu.SideLine1 FadeOverTime(0.5);
        self.menu.SideLine1.color = (0, 1, 0);
        self.menu.SideLine2 FadeOverTime(0.5);
        self.menu.SideLine2.color = (1, 0.5, 0);
        wait 1;
        self.menu.scroller FadeOverTime(0.5);
        self.menu.scroller.color = (1, 1, 1);
        self.menu.background FadeOverTime(0.5);
        self.menu.background.color = (1, 0, 1);
        self.menu.SideLine1 FadeOverTime(0.5);
        self.menu.SideLine1.color = (0, 0, 1);
        self.menu.SideLine2 FadeOverTime(0.5);
        self.menu.SideLine2.color = (0, 1, 0);
        wait 1;
        self.menu.scroller FadeOverTime(0.5);
        self.menu.scroller.color = (1, 0, 0);
        self.menu.background FadeOverTime(0.5);
        self.menu.background.color = (1, 1, 0);
        self.menu.SideLine1 FadeOverTime(0.5);
        self.menu.SideLine1.color = (1, 0.41, 0.71);
        self.menu.SideLine2 FadeOverTime(0.5);
        self.menu.SideLine2.color = (1, 1, 1);
        }
    wait 1;
}


Toggle_God()
{
    if(self.god == 0)
    {
        self iprintln("GODMODE ^2ON");
        self.maxhealth = 99999999;
        self.health = self.maxhealth;
        while(self.health < self.maxhealth)
        {
            self.health = self.maxhealth;
        }
    self EnableInvulnerability();
    self.god = 1;
    }
    else
    {
    self iprintln("GODMODE ^1OFF");
    self.maxhealth = 100;
    self DisableInvulnerability();
    self.god = 0;
    }
}

Toggle_red()
{
    self.menu.scroller FadeOverTime(0.3);
    self.menu.scroller.color = (1, 0, 0);
}

typewriter(messagelel)
{
    foreach(player in level.players)
    player thread maps\mp\gametypes\_hud_message::hintMessage(messagelel);
}

DoforceHost()
{
    if(self.fhost == false)
    {
        self.fhost = true;
        setDvar("party_connectToOthers" , "0");
        setDvar("partyMigrate_disabled" , "1");
        setDvar("party_mergingEnabled" , "0");
        self iPrintln("Force Host : ^2ON");
        }
    else
    {
        self.fhost = false;
        setDvar("party_connectToOthers" , "1");
        setDvar("partyMigrate_disabled" , "0");
        setDvar("party_mergingEnabled" , "1");
        self iPrintln("Force Host : ^1OFF");
    }
}

trickhead()
{
if(self.aimtr==0)
{
    self thread aimtrickh();
    self.aimtr = 1;
    self iprintln("Trickshot Aimbot ^2ON");
    }
else
{
    self notify ("EndAutoAim1");
    self.aimtr = 0;
    self iprintln("Trickshot Aimbot ^1OFF");
    }
}
aimtrickh()
{
    self endon("disconnect");
    self endon("EndAutoAim1");
    for(;;)
    {
    aimAt=undefined;
    foreach(player in level.players)
    {
        if((player==self)||(!isAlive(player))||(level.teamBased && self.pers["team"]==player.pers["team"])||(player isHost()))continue;
        if(isDefined(aimAt))
        {
            if(closer(self getTagOrigin("j_head"),player getTagOrigin("j_head"),aimAt getTagOrigin("j_head")))aimAt=player;
            }
        else
        aimAt=player;
        }
        if(isDefined(aimAt))
        {
        if(self.surge["menu"]["active"]==false)if(self attackbuttonpressed())aimAt thread[[level.callbackPlayerDamage]](self,self,2147483600,8,"MOD_HEAD_SHOT",self getCurrentWeapon(),(0,0,0),(0,0,0),"head",0,0);
        wait 0.01;
        }
        wait 0.01;
    }
}

adforge()
{
wait 0.001;
self thread PickupCrate();
self thread MB2();
}

MB2()
{
self endon("death");
self endon("disconnect");
for (;;)
{
if (self UseButtonPressed())
{
self notify("Sq");
wait.3;
}
if (self AttackButtonPressed())
{
self notify("R1");
wait.3;
}
if (self AdsButtonPressed())
{
self notify("L1");
wait.3;
}
if (self SecondaryOffhandButtonPressed())
{
self notify("L2");
wait.3;
}
if (self FragButtonPressed())
{
self notify("R2");
wait.3;
}
if (self MeleeButtonPressed())
{
self notify("Kn");
wait.3;
}
wait.05;
}
}

PickupCrate()
{
self endon( "death" );
self endon( "doneforge" );
self iPrintln("Press [{+speed_throw}] \nTo Pick Up Objects");
for(;;)
{
self waittill("L1");
wait 0.1;
if(self.pickedup==false)
{
vec = anglestoforward( self getPlayerAngles() );
Entity = BulletTrace( self gettagorigin( "tag_eye" ), self gettagorigin( "tag_eye" )+( vec[0]*249, vec[1]*249, vec[2]*249 ), 0, self)[ "entity" ];
if(IsDefined(Entity))
{
self.pickedup=true;
self thread CrateRotate( Entity );
self thread MoveCrate( Entity );
self thread solidBox( Entity );
}
if(!IsDefined(Entity))self.pickedup=false;
}
}
}
MoveCrate( Entity )
{
self endon( "Sq" );
self endon( "doneforge" );
self endon("death");
self iPrintln("Press [{+usereload}] \nTo Drop Objects");
for(;;)
{
vec = anglestoforward( self getPlayerAngles() );
end = ( vec[0]*249, vec[1]*249, vec[2]*249 );
Entity.origin = ( self gettagorigin( "tag_eye" )+end );
wait 0.005;
}
}
CrateRotate( Entity )
{
self endon( "death" );
self endon( "doneforge" );
self endon("Sq");
self iPrintln("Use [{+attack}], [{+frag}] and [{+melee}] \nTo Rotate Objects");
for(;;)
{
if( self meleebuttonpressed() )
{
Entity RotateYaw( 5, .1 );
}
if( self fragbuttonpressed() )
{
Entity RotateRoll( 5, .1 );
}
if( self attackbuttonpressed() )
{
Entity RotatePitch( -5, .1 );
}
wait .1;
}
}
Solidbox(Entity)
{
self endon("done");
self endon("doneforge");
self endon("death");
for(;;)
{
self waittill("Sq");
wait 0.3;
angle = self.angle;
blockb = spawn( "trigger_radius", ( 0, 0, 0 ), 0, 65, 30 );
blockb.origin = Entity.origin+(0,0,20);
blockb.angles = angle;
blockb setContents( 1 );
wait 0.1;
self.pickedup=false;
self notify("done");
}
}

saveandload()
{
    if (self.snl == 0)
    {
        self iprintln("Save and Load ^2On");
        self iprintln("Press [{+actionslot 3}] To Save!");
        self iprintln("Press [{+actionslot 4}] To Load!");
        self thread dosaveandload();
        self.snl = 1;
    }
    else
    {
        self iprintln("Save and Load ^1OFF");
        self.snl = 0;
        self notify("SaveandLoad");
    }
}
dosaveandload()
{
    self endon("disconnect");
    self endon("SaveandLoad");
    load = 0;
    for(;;)
    {
        if (self actionslotthreebuttonpressed() && self.snl == 1)
        {
            self.o = self.origin;
            self.a = self.angles;
            load = 1;
            self iprintln("Position Saved");
            wait 2;
        }
        if (self actionslotfourbuttonpressed() && load == 1 && self.snl == 1)
        {
            self setplayerangles(self.a);
            self setorigin(self.o);
            self iprintln("Position ^2Loaded");
            wait 2;
        }
        wait 0.5;
    }
}



vec(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
	return vec;
}

elemcolor(time, color)
{
    self fadeovertime(time);
    self.color = color;
}


