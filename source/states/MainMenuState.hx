package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.ui.FlxButton;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;

import states.editors.MasterEditorMenu;
import options.OptionsState;
import options.GameplayChangersSubstate;
import backend.Song;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3-Final'; // This is also used for Discord RPC
	public static var catnapVersion:String = '1.0';
	public static var curSelected:Int = 0;
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	var spritePath:String = 'mainmenu/';
        var startButton:FlxButton;
	var creditsButton:FlxButton;
	var optionsButton:FlxButton;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(spritePath + 'bg'));
		bg.frames = Paths.getSparrowAtlas(spritePath + 'bg');
		bg.animation.addByPrefix('play', 'idle', 24, true);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scale.set(0.666666, 0.666666);
		bg.updateHitbox();
		bg.animation.play('play');
		add(bg);


		var psychVer:FlxText = new FlxText(975, FlxG.height - 24, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		
		var CatoNapoVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Godsent Gaslit v" + catnapVersion, 12);
		CatoNapoVer.scrollFactor.set();
		CatoNapoVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(CatoNapoVer);

		addVirtualPad('NONE', 'NONE');

		startButton = new FlxButton(0, 0, " ", startButtonPress);
		startButton.loadGraphic(Paths.image(spritePath + 'buttonStart'), true, 583, 191);
		startButton.frames = Paths.getSparrowAtlas(spritePath + 'buttonStart');
		startButton.animation.addByPrefix('highlighted', 'start big0', 24, true);
		startButton.animation.addByPrefix('idle', 'start small0', 24, true);
		startButton.x = 500;
		startButton.y = 600;
		startButton.scale.set(0.5, 0.5);
		startButton.updateHitbox();
		add(startButton);

		creditsButton = new FlxButton(0, 0, " ", creditsButtonPressed);
		creditsButton.loadGraphic(Paths.image(spritePath + 'buttonCredits'), true, 583, 191);
		creditsButton.frames = Paths.getSparrowAtlas(spritePath + 'buttonCredits');
		creditsButton.animation.addByPrefix('highlighted', 'credits big0', 24, true);
		creditsButton.animation.addByPrefix('idle', 'credits small0', 24, true);
		creditsButton.x = 900;
		creditsButton.y = 600;
		creditsButton.scale.set(0.5, 0.5);
		creditsButton.updateHitbox();
		add(creditsButton);

		optionsButton = new FlxButton(0, 0, " ", optionsButtonPress);
		optionsButton.loadGraphic(Paths.image(spritePath + 'buttonOptions'), true, 583, 191);
		optionsButton.frames = Paths.getSparrowAtlas(spritePath + 'buttonOptions');
		optionsButton.animation.addByPrefix('highlighted', 'options big0', 24, true);
		optionsButton.animation.addByPrefix('idle', 'options small0', 24, true);
		optionsButton.x = 100;
		optionsButton.y = 600;
		optionsButton.scale.set(0.5, 0.5);
		optionsButton.updateHitbox();
		add(optionsButton);
		
		startButton.onOver.callback = startButtonHighlight.bind();
		creditsButton.onOver.callback = creditsButtonHighlight.bind();
		optionsButton.onOver.callback = optionsButtonHighlight.bind();
		startButton.onOut.callback = startButtonDeselect.bind(); 
		creditsButton.onOut.callback = creditsButtonDeselect.bind(); 
		optionsButton.onOut.callback = optionsButtonDeselect.bind(); 

		super.create();
	
		startButton.animation.play('idle');
		creditsButton.animation.play('idle');
		optionsButton.animation.play('idle');
	}

	// Start button stuff
	function startButtonPress()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		persistentUpdate = false;
		PlayState.SONG = Song.loadFromJson('bedtime', 'bedtime');
		new FlxTimer().start(0.1, function(tmr:FlxTimer) {
			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
		FlxG.sound.music.volume = 0;
	}

	function startButtonHighlight()
	{
		persistentUpdate = false;
		startButton.animation.play('highlighted');
	}

	function startButtonDeselect()
	{
		persistentUpdate = false;
		startButton.animation.play('idle');
	}

	// Credits button stuff
	function creditsButtonPressed()
	{
		persistentUpdate = false;
		creditsButton.animation.play('idle');
		MusicBeatState.switchState(new CreditsState());
	}

	function creditsButtonHighlight()
	{
		persistentUpdate = false;
		creditsButton.animation.play('highlighted');
	}

	function creditsButtonDeselect()
	{
		persistentUpdate = false;
		creditsButton.animation.play('idle');
	}

	// Options button stuff
	function optionsButtonPress()
	{
		persistentUpdate = false;
		optionsButton.animation.play('idle');
		MusicBeatState.switchState(new OptionsState());
		OptionsState.onPlayState = false;
		if (PlayState.SONG != null) {
			PlayState.SONG.arrowSkin = null;
			PlayState.SONG.splashSkin = null;
			PlayState.stageUI = 'normal';
		}
	}

	function optionsButtonHighlight()
	{
		persistentUpdate = false;
		optionsButton.animation.play('highlighted');
	}

	function optionsButtonDeselect()
	{
		persistentUpdate = false;
		optionsButton.animation.play('idle');
	}

	override function update(elapsed:Float)
	{

		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

			if (controls.justPressed('debug_1')) {
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		if(FlxG.keys.justPressed.CONTROL)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}

		super.update(elapsed);
	}

	override function closeSubState()
	{
		persistentUpdate = true;
		super.closeSubState();
	}
}
