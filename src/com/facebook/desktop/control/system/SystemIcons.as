package com.facebook.desktop.control.system
{
	import com.facebook.desktop.control.Controller;
	import com.facebook.desktop.control.api.GetActivityNotifications;
	import com.facebook.desktop.control.api.GetStreamUpdates;
	import com.facebook.desktop.control.notification.ToastManager;
	import com.facebook.desktop.control.util.Util;
	import com.facebook.desktop.model.Model;
	import com.facebook.desktop.model.cache.UserCache;
	import com.facebook.graph.FacebookDesktop;
	
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Loader;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.charts.AreaChart;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;
	
	public class SystemIcons
	{
		private static var iconLoader:Loader = new Loader();
		private static var systemTrayIcon:SystemTrayIcon;
		private static var dockIcon:DockIcon;
		
		private static var aboutCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.about"));
		private static var updateStatusCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.updateStatus"));
		private static var pausePlayCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.pause"));
		private static var checkForUpdatesCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.checkForUpdates"));
		private static var replayLatestFiveUpdatesCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.replayLatestFive"));
		private static var settingsCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.settings"));
		private static var loginCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.login"));
		private static var logoutCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.logout"));
		private static var exitCommand:NativeMenuItem = new NativeMenuItem(ResourceManager.getInstance().getString("resources", "contextMenu.exit"));
		private static var topSeparator:NativeMenuItem = new NativeMenuItem("", true);
		private static var bottomSeparator:NativeMenuItem = new NativeMenuItem("", true);
		
		private static var model:Model = Model.instance;
		private static var controller:Controller = Controller.instance;
		private static var userCache:UserCache = UserCache.instance;
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.system.SystemIcons");
		
		public static function init():void
		{
			var supportsSystemTray:Boolean = NativeApplication.supportsSystemTrayIcon;
			var supportsDock:Boolean = NativeApplication.supportsDockIcon;
			
			// initialize commands - add event-handlers here...ONCE
			aboutCommand.addEventListener(Event.SELECT, aboutHandler);
			updateStatusCommand.addEventListener(Event.SELECT, updateStatusHandler);
			checkForUpdatesCommand.addEventListener(Event.SELECT, checkForUpdatesHandler);
			replayLatestFiveUpdatesCommand.addEventListener(Event.SELECT, replayLatestFiveUpdatesHandler);
			pausePlayCommand.addEventListener(Event.SELECT, pausePlayHandler);
			settingsCommand.addEventListener(Event.SELECT, settingsHandler);
			logoutCommand.addEventListener(Event.SELECT, logoutHandler);
			loginCommand.addEventListener(Event.SELECT, loginHandler);
			exitCommand.addEventListener(Event.SELECT, exitHandler);
			
			// listen to changes in language so I can reset the context menus
			ResourceManager.getInstance().addEventListener(Event.CHANGE, changeLanguage);
			
			if (supportsSystemTray)
			{
				logger.info("Initializing system-tray icon and menu");
				iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
				iconLoader.load(new URLRequest("/assets/icons/paused-icon16.png"));
				systemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
				systemTrayIcon.tooltip = ResourceManager.getInstance().getString("resources", "application.name");
				systemTrayIcon.menu = createIconMenu(supportsSystemTray);
				systemTrayIcon.addEventListener(MouseEvent.CLICK, iconClick);
			}  // if statement
			
			if (supportsDock)
			{
				logger.info("Initializing dock icon and menu");
				iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
				iconLoader.load(new URLRequest("/assets/icons/paused-icon128.png"));
				dockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				dockIcon.menu = createIconMenu(supportsSystemTray);
				NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, updateStatusHandler);
			}  // if statement
			
			function iconLoadComplete(event:Event):void
			{
				NativeApplication.nativeApplication.icon.bitmaps=[event.target.content.bitmapData];
			}  // iconLoadComplete
			
			function iconClick(event:Event):void
			{
				updateStatusHandler();
//				flash.net.navigateToURL(new URLRequest("http://www.facebook.com/"));
			}  // iconClick
			
			function changeLanguage(event:Event):void
			{
				aboutCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.about");
				updateStatusCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.updateStatus");
				pausePlayCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.pause");
				checkForUpdatesCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.checkForUpdates");
				replayLatestFiveUpdatesCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.replayLatestFive");
				settingsCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.settings");
				loginCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.login");
				logoutCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.logout");
				exitCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.exit");
			}  // changeLanguage
		}  // init
		
		public static function changeMenus(loggedIn:Boolean):void
		{
			if (loggedIn)
			{
				logger.info("Changing menus to logged-in set of menus");
			}  // if statement
			else
			{
				logger.info("Changing menus to logged-out set of menus");
			}  // else statement
			
			var supportsSystemTray:Boolean = NativeApplication.supportsSystemTrayIcon;
			var supportsDock:Boolean = NativeApplication.supportsDockIcon;
			
			if (supportsSystemTray)
			{
				if (loggedIn)
				{
					// clear out menu items
					systemTrayIcon.menu.removeAllItems();
					
					// re-build menu
					systemTrayIcon.menu.addItem(aboutCommand);
					systemTrayIcon.menu.addItem(updateStatusCommand);
					systemTrayIcon.menu.addItem(topSeparator);
					systemTrayIcon.menu.addItem(checkForUpdatesCommand);
					systemTrayIcon.menu.addItem(replayLatestFiveUpdatesCommand);
					systemTrayIcon.menu.addItem(pausePlayCommand);
					systemTrayIcon.menu.addItem(bottomSeparator);
					systemTrayIcon.menu.addItem(settingsCommand);
					systemTrayIcon.menu.addItem(logoutCommand);
					systemTrayIcon.menu.addItem(exitCommand);
				}  // if statement
				else
				{
					// clear out menu items
					systemTrayIcon.menu.removeAllItems();
					
					// re-build menu
					systemTrayIcon.menu.addItem(aboutCommand);
					systemTrayIcon.menu.addItem(topSeparator);
					systemTrayIcon.menu.addItem(settingsCommand);
					systemTrayIcon.menu.addItem(loginCommand);
					systemTrayIcon.menu.addItem(exitCommand);
				}  // else statement
			}  // if statement
			else
			{
				if (loggedIn)
				{
					// clear out menu items
					dockIcon.menu.removeAllItems();
					
					// re-build menu
					dockIcon.menu.addItem(aboutCommand);
					dockIcon.menu.addItem(updateStatusCommand);
					dockIcon.menu.addItem(topSeparator);
					dockIcon.menu.addItem(checkForUpdatesCommand);
					dockIcon.menu.addItem(replayLatestFiveUpdatesCommand);
					dockIcon.menu.addItem(pausePlayCommand);
					dockIcon.menu.addItem(bottomSeparator);
					dockIcon.menu.addItem(settingsCommand);
					dockIcon.menu.addItem(logoutCommand);
				}  // if statement
				else
				{
					// clear out menu items
					dockIcon.menu.removeAllItems();
					
					// re-build menu
					dockIcon.menu.addItem(aboutCommand);
					dockIcon.menu.addItem(topSeparator);
					dockIcon.menu.addItem(settingsCommand);
					dockIcon.menu.addItem(loginCommand);
				}  // else statement
			}  // else statement
		}  // changeMenus
		
		public static function changeIcon(live:Boolean):void
		{
			logger.info("Proceeding to change the icon");
			var supportsSystemTray:Boolean = NativeApplication.supportsSystemTrayIcon;
			var supportsDock:Boolean = NativeApplication.supportsDockIcon;
			
			var icon:String = null;
			
			if (supportsSystemTray)
			{
				if (live)
				{
					logger.info("Changing system-tray icon to live 16x16 image");
					icon = "/assets/icons/icon16.png";
				}  // if statement
				else
				{
					logger.info("Changing system-tray icon to paused 16x16 image");
					icon = "/assets/icons/paused-icon16.png"
				}  // else statement
				
				iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
				iconLoader.load(new URLRequest(icon));
			}  // if statement
			
			if (supportsDock)
			{
				if (live)
				{
					logger.info("Changing dock icon to live 128x128 image");
					icon = "/assets/icons/icon128.png";
				}  // if statement
				else
				{
					logger.info("Changing dock icon to paused 128x128 image");
					icon = "/assets/icons/paused-icon128.png"
				}  // else statement
				
				iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
				iconLoader.load(new URLRequest(icon));
			}  // if statement
			
			function iconLoadComplete(event:Event):void
			{
				NativeApplication.nativeApplication.icon.bitmaps=[event.target.content.bitmapData];
			}  // iconLoadComplete
		}  // changeIcon
		
		private static function createIconMenu(supportsSystemTray:Boolean):NativeMenu
		{
			var iconMenu:NativeMenu = new NativeMenu();
			iconMenu.addItem(aboutCommand);
			iconMenu.addItem(topSeparator);
			
			if (supportsSystemTray)
			{
				iconMenu.addItem(settingsCommand);
				iconMenu.addItem(loginCommand);
				iconMenu.addItem(exitCommand);
			}  // if statement
			else
			{
				iconMenu.addItem(settingsCommand);
				iconMenu.addItem(loginCommand);
			}  // else statement
			
			return iconMenu;
		}  // createIconMenu
		
		private static function aboutHandler(event:Event = null):void
		{
			controller.openAboutWindow();
		}  // aboutHandler
		
		private static function updateStatusHandler(event:Event = null):void
		{
			// Only show update-window if we're connected (we're assuming that
			// the connect logic has done it's job and put the update-status menu-item
			// in the menu upon connect.
			if ((dockIcon != null && dockIcon.menu != null && dockIcon.menu.containsItem(updateStatusCommand)) ||
				(systemTrayIcon != null && systemTrayIcon.menu != null && systemTrayIcon.menu.containsItem(updateStatusCommand)))
			{
				logger.info("Attempting to show/hide status-update window");
				controller.openStatusUpdateWindow();
			}  // if statement
			else
			{
				logger.info("System-tray/dock icon clicked but user not logged in. Suppressing display of status-update window.");
			}  // else statement
		}  // updateStatusHandler
		
		private static function loginHandler(event:Event = null):void
		{
			logger.info("Logging in...");
			FacebookDesktop.login(loginHandler, Model.REQUIRED_PERMISSIONS);
			
			function loginHandler(session:Object, fail:Object):void
			{
				if (session != null)
				{
					logger.info("Login from system-tray successful");
					
					// tell the model
					model.connected = true;
					
					// adjust icon and menus
					SystemIcons.changeIcon(true);
					SystemIcons.changeMenus(true);
					
					// show login popup
					ToastManager.show(ResourceManager.getInstance().getString("resources", "toast.welcome"), null, "http://www.facebook.com/apps/application.php?id=95615112563", FacebookDesktop.getImageUrl(session.user.id));
					model.latestFiveUpdates.removeAll();
					
					// get latest update so that we can start receiving pop-ups for *new* updates
					FacebookDesktop.api("/me/home", getStreamHandler, {limit:1});
				}  // if statement
			}  // loginHandler
			
			function getStreamHandler(result:Object, fail:Object):void
			{
				if (!fail && result is Array && (result as Array).length > 0)
				{
					// set latest-story-update time
					var latestStreamUpdate:Date = Util.RFC3339toDate(result[0].created_time);
					logger.info("Setting latest update time to " + latestStreamUpdate.toString());
					model.latestStreamUpdate = (latestStreamUpdate.time / 1000).toString();
				}  // if statement
				else
				{
					logger.error("Request to get latest update has failed!  Error object: " + fail);
				}  // else statement
			}  // getStreamHandler
		}  // loginHandler
		
		private static function logoutHandler(event:Event = null):void
		{
			logger.info("Logging out! Goodbye!");
			
			changeIcon(false);
			ToastManager.show(ResourceManager.getInstance().getString("resources", "toast.goodbye"), "");
			
			// clear toast-history
			model.latestFiveUpdates.removeAll();
			model.connected = false;
			
			FacebookDesktop.logout();
			
			SystemIcons.changeMenus(false);
		}  // logoutHandler
		
		private static function settingsHandler(event:Event = null):void
		{
			controller.openSettingsWindow();
		}  // settingsHandler
		
		private static function pausePlayHandler(event:Event = null):void
		{
			if (pausePlayCommand.label == ResourceManager.getInstance().getString("resources", "contextMenu.pause"))
			{
				logger.info("Pausing notifications");
				changeIcon(false);
				model.paused = true;
				pausePlayCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.resume");
			}  // if statement
			else
			{
				logger.info("Resuming notifications");
				changeIcon(true);
				model.paused = false;
				pausePlayCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.pause");
			}  // else statement
		}  // pausePlayHandler
		
		private static function checkForUpdatesHandler(event:Event = null):void
		{
			logger.info("Forcing a check for updates");
			
			var totalUpdates:int = 0;
			
			// stream-updates
			var getStreamUpdatesCommand:GetStreamUpdates = new GetStreamUpdates();
			getStreamUpdatesCommand.previousUpdateTime = model.latestStreamUpdate;
			getStreamUpdatesCommand.execute(getStreamUpdatesHandler);
			
			function getStreamUpdatesHandler(updates:Object, fail:Object):void
			{
				if (fail == null && updates != null && updates is Array)
				{
					totalUpdates += (updates as Array).length;
				}  // if statement
				
				// likes and comments
				var getActivityNotificationsCommand:GetActivityNotifications = new GetActivityNotifications();
				getActivityNotificationsCommand.includeRead = "0";
				getActivityNotificationsCommand.startTime = model.latestActivityUpdate;
				getActivityNotificationsCommand.execute(getActivityNotificationsHandler);
			}  // getStreamUpdatesHandler
			
			function getActivityNotificationsHandler(result:Object, fail:Object):void
			{
				if (fail == null && result != null && result is Array)
				{
					totalUpdates += (result as Array).length;
				}  // if statement
				
				if (totalUpdates == 0)
				{
					logger.info("No new updates to show");
					ToastManager.show(ResourceManager.getInstance().getString("resources", "toast.noNewUpdates"), "");
				}  // if statement
			}  // getActivityNotificationsHandler
		}  // checkForUpdatesHandler
		
		private static function replayLatestFiveUpdatesHandler(event:Event = null):void
		{
			logger.info("Displaying latest 5 updates");
			ToastManager.showLatestFiveUpdates();
		}  // replayLatestFiveUpdatesHandler
		
		private static function exitHandler(event:Event = null):void
		{
			logger.info("Exiting the application.");
			NativeApplication.nativeApplication.exit();
		}  // exitHandler
	}  // class declaration
}  // package