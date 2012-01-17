package com.facebook.desktop.control.system
{
	import com.charlesbihis.engine.notification.NotificationManager;
	import com.facebook.desktop.FacebookDesktopConst;
	import com.facebook.desktop.control.Controller;
	import com.facebook.desktop.control.api.GetAdditionalNotifications;
	import com.facebook.desktop.control.api.GetNewsFeed;
	import com.facebook.desktop.control.api.GetNotifications;
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
	import flash.net.URLRequest;
	
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
		private static var eventInvitesCommand:NativeMenuItem = new NativeMenuItem(" ");
		private static var friendRequestsCommand:NativeMenuItem = new NativeMenuItem(" ");
		private static var groupInvitesCommand:NativeMenuItem = new NativeMenuItem(" ");
		private static var unreadMessagesCommand:NativeMenuItem = new NativeMenuItem(" ");
		private static var newPokesCommand:NativeMenuItem = new NativeMenuItem(" ");
		private static var newSharesCommand:NativeMenuItem = new NativeMenuItem(" ");
		private static var topSeparator:NativeMenuItem = new NativeMenuItem("", true);
		private static var middleSeparator:NativeMenuItem = new NativeMenuItem("", true);
		private static var bottomSeparator:NativeMenuItem = new NativeMenuItem("", true);
		
		private static var model:Model = Model.instance;
		private static var notificationManager:NotificationManager = NotificationManager.instance;
		private static var controller:Controller = Controller.instance;
		private static var userCache:UserCache = UserCache.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.system.SystemIcons");
		
		private static var supportsSystemTray:Boolean;
		private static var supportsDock:Boolean;
		
		public static function init():void
		{
			supportsSystemTray = NativeApplication.supportsSystemTrayIcon;
			supportsDock = NativeApplication.supportsDockIcon;
			
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
			eventInvitesCommand.addEventListener(Event.SELECT, eventInvitesHandler);
			friendRequestsCommand.addEventListener(Event.SELECT, friendRequestsHandler);
			groupInvitesCommand.addEventListener(Event.SELECT, groupInvitesHandler);
			unreadMessagesCommand.addEventListener(Event.SELECT, unreadMessagesHandler);
			newPokesCommand.addEventListener(Event.SELECT, newPokesHandler);
			newSharesCommand.addEventListener(Event.SELECT, newSharesHandler);
			
			// listen to changes in language so I can reset the context menus
			ResourceManager.getInstance().addEventListener(Event.CHANGE, changeLanguage);
			
			if (supportsSystemTray)
			{
				log.info("Initializing system-tray icon and menu");
				iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
				iconLoader.load(new URLRequest("/assets/icons/paused-icon16.png"));
				systemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
				systemTrayIcon.tooltip = ResourceManager.getInstance().getString("resources", "application.name");
				systemTrayIcon.menu = createIconMenu(supportsSystemTray);
				systemTrayIcon.addEventListener(MouseEvent.CLICK, iconClick);
			}  // if statement
			
			if (supportsDock)
			{
				log.info("Initializing dock icon and menu");
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
				// TODO: add this to settings
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
		
		public static function changedLoggedInMenuState(loggedIn:Boolean):void
		{
			log.info("Changing menus to " + (loggedIn ? "logged-in" : "logged-out") + " set of menus");
			
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
		}  // changedLoggedInMenuState
		
		public static function addAdditionalNotificationsToMenu(additionalNotifications:Object):void
		{
			eventInvitesCommand.label = additionalNotifications.event_invites.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.eventInvitation") : ResourceManager.getInstance().getString("resources", "notification.eventInvitationsBegin") + " " + additionalNotifications.event_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.eventInvitationsEnd");
			friendRequestsCommand.label = additionalNotifications.friend_requests.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.friendRequest") : ResourceManager.getInstance().getString("resources", "notification.friendRequestsBegin") + " " + additionalNotifications.friend_requests.length + " " + ResourceManager.getInstance().getString("resources", "notification.friendRequestsEnd");
			groupInvitesCommand.label = additionalNotifications.group_invites.length == 1 ? ResourceManager.getInstance().getString("resources", "notification.groupInvitation") : ResourceManager.getInstance().getString("resources", "notification.groupInvitationsBegin") + " " + additionalNotifications.group_invites.length + " " + ResourceManager.getInstance().getString("resources", "notification.groupInvitationsEnd");
			unreadMessagesCommand.label = additionalNotifications.messages.unread == 1 ? ResourceManager.getInstance().getString("resources", "notification.unreadMessage") : ResourceManager.getInstance().getString("resources", "notification.unreadMessagesBegin") + " " + additionalNotifications.messages.unread + " " + ResourceManager.getInstance().getString("resources", "notification.unreadMessagesEnd");
			newPokesCommand.label = ResourceManager.getInstance().getString("resources", "notification.poked");
			newSharesCommand.label = ResourceManager.getInstance().getString("resources", "notification.sharedLink");
			
			var notificationCount:int = 0;
			if (supportsSystemTray)
			{
				// clear out menu items
				systemTrayIcon.menu.removeAllItems();
				
				// re-build top menu items
				systemTrayIcon.menu.addItem(aboutCommand);
				systemTrayIcon.menu.addItem(updateStatusCommand);
				systemTrayIcon.menu.addItem(topSeparator);
				systemTrayIcon.menu.addItem(checkForUpdatesCommand);
				systemTrayIcon.menu.addItem(replayLatestFiveUpdatesCommand);
				systemTrayIcon.menu.addItem(pausePlayCommand);
				
				// insert middle menu items
				if (additionalNotifications.event_invites.length > 0 || additionalNotifications.friend_requests.length > 0 || additionalNotifications.group_invites.length > 0 ||
					additionalNotifications.messages.unread > 0 || additionalNotifications.pokes.unread > 0 || additionalNotifications.shares.unread > 0)
				{
					systemTrayIcon.menu.addItem(middleSeparator);
					
					// event invites
					if (additionalNotifications.event_invites.length > 0)
					{
						systemTrayIcon.menu.addItem(eventInvitesCommand);
						notificationCount += additionalNotifications.event_invites.length;
					}  // if statement
					
					// friend requests
					if (additionalNotifications.friend_requests.length > 0)
					{
						systemTrayIcon.menu.addItem(friendRequestsCommand);
						notificationCount += additionalNotifications.event_invites.length;
					}  // if statement
					
					// group invites
					if (additionalNotifications.group_invites.length > 0)
					{
						systemTrayIcon.menu.addItem(groupInvitesCommand);
						notificationCount += additionalNotifications.group_invites.length;
					}  // if statement
					
					// unread messages
					if (additionalNotifications.messages.unread > 0)
					{
						systemTrayIcon.menu.addItem(unreadMessagesCommand);
						notificationCount += additionalNotifications.messages.unread;
					}  // if statement
					
					// pokes
					if (additionalNotifications.pokes.unread > 0)
					{
						systemTrayIcon.menu.addItem(newPokesCommand);
						notificationCount += additionalNotifications.pokes.unread;
					}  // if statement
					
					// shares
					if (additionalNotifications.shares.unread > 0)
					{
						systemTrayIcon.menu.addItem(newSharesCommand);
						notificationCount += additionalNotifications.shares.unread;
					}  // if statement
				}  // if statement
				
				// re-build bottom menu items
				systemTrayIcon.menu.addItem(bottomSeparator);
				systemTrayIcon.menu.addItem(settingsCommand);
				systemTrayIcon.menu.addItem(logoutCommand);
				systemTrayIcon.menu.addItem(exitCommand);
			}  // if statement
			else
			{
				// clear out menu items
				dockIcon.menu.removeAllItems();
				
				// re-build top menu items
				dockIcon.menu.addItem(aboutCommand);
				dockIcon.menu.addItem(updateStatusCommand);
				dockIcon.menu.addItem(topSeparator);
				dockIcon.menu.addItem(checkForUpdatesCommand);
				dockIcon.menu.addItem(replayLatestFiveUpdatesCommand);
				dockIcon.menu.addItem(pausePlayCommand);
				
				// insert middle menu items
				if (additionalNotifications.event_invites.length > 0 || additionalNotifications.friend_requests.length > 0 || additionalNotifications.group_invites.length > 0 ||
					additionalNotifications.messages.unread > 0 || additionalNotifications.pokes.unread > 0 || additionalNotifications.shares.unread > 0)
				{
					dockIcon.menu.addItem(middleSeparator);
					
					// event invites
					if (additionalNotifications.event_invites.length > 0)
					{
						dockIcon.menu.addItem(eventInvitesCommand);
						notificationCount += additionalNotifications.event_invites.length;
					}  // if statement
					
					// friend requests
					if (additionalNotifications.friend_requests.length > 0)
					{
						dockIcon.menu.addItem(friendRequestsCommand);
						notificationCount += additionalNotifications.event_invites.length;
					}  // if statement
					
					// group invites
					if (additionalNotifications.group_invites.length > 0)
					{
						dockIcon.menu.addItem(groupInvitesCommand);
						notificationCount += additionalNotifications.group_invites.length;
					}  // if statement
					
					// unread messages
					if (additionalNotifications.messages.unread > 0)
					{
						dockIcon.menu.addItem(unreadMessagesCommand);
						notificationCount += additionalNotifications.messages.unread;
					}  // if statement
					
					// pokes
					if (additionalNotifications.pokes.unread > 0)
					{
						dockIcon.menu.addItem(newPokesCommand);
						notificationCount += additionalNotifications.pokes.unread;
					}  // if statement
					
					// shares
					if (additionalNotifications.shares.unread > 0)
					{
						dockIcon.menu.addItem(newSharesCommand);
						notificationCount += additionalNotifications.shares.unread;
					}  // if statement
				}  // if statement
				
				// re-build bottom menu items
				dockIcon.menu.addItem(bottomSeparator);
				dockIcon.menu.addItem(settingsCommand);
				dockIcon.menu.addItem(logoutCommand);
			}  // else statement
			
			// TODO: change icon based on notificationCount
		}  // addAdditionalNotificationsToMenu
		
		public static function changeIcon(live:Boolean):void
		{
			log.info("Proceeding to change the icon");
			
			var icon:String = null;
			
			if (supportsSystemTray)
			{
				if (live)
				{
					log.info("Changing system-tray icon to live 16x16 image");
					icon = "/assets/icons/icon16.png";
				}  // if statement
				else
				{
					log.info("Changing system-tray icon to paused 16x16 image");
					icon = "/assets/icons/paused-icon16.png"
				}  // else statement
				
				iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
				iconLoader.load(new URLRequest(icon));
			}  // if statement
			
			if (supportsDock)
			{
				if (live)
				{
					log.info("Changing dock icon to live 128x128 image");
					icon = "/assets/icons/icon128.png";
				}  // if statement
				else
				{
					log.info("Changing dock icon to paused 128x128 image");
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
				log.info("Attempting to show/hide status-update window");
				controller.openStatusUpdateWindow();
			}  // if statement
			else
			{
				log.info("System-tray/dock icon clicked but user not logged in. Suppressing display of status-update window.");
			}  // else statement
		}  // updateStatusHandler
		
		// TODO: match login logic in Main.mxml
		private static function loginHandler(event:Event = null):void
		{
			log.info("Logging in...");
			FacebookDesktop.login(loginHandler, Model.REQUIRED_PERMISSIONS);
			
			function loginHandler(session:Object, fail:Object):void
			{
				if (session != null)
				{
					log.info("Login from system-tray successful");
					
					// tell the model
					model.connected = true;
					
					// adjust icon and menus
					SystemIcons.changeIcon(true);
					SystemIcons.changedLoggedInMenuState(true);
					
					// show login popup
					notificationManager.show(ResourceManager.getInstance().getString("resources", "toast.welcome"), "", FacebookDesktop.getImageUrl(session.user.id), FacebookDesktopConst.FACEBOOK_DESKTOP_PAGE);
					notificationManager.clearLatestFiveUpdates();
					
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
					log.info("Setting latest update time to " + latestStreamUpdate.toString());
					model.latestNewsFeedUpdate = (latestStreamUpdate.time / 1000).toString();
				}  // if statement
				else
				{
					log.error("Request to get latest update has failed!  Error object: " + fail);
				}  // else statement
			}  // getStreamHandler
		}  // loginHandler
		
		private static function logoutHandler(event:Event = null):void
		{
			log.info("Logging out! Goodbye!");
			
			changeIcon(false);
			notificationManager.show(ResourceManager.getInstance().getString("resources", "toast.goodbye"), "", FacebookDesktopConst.FACEBOOK_NOTIFICATION_DEFAULT_IMAGE);
			
			// clear toast-history
			notificationManager.clearLatestFiveUpdates();
			model.connected = false;
			model.currentUser = null;
			
			FacebookDesktop.logout();
			
			SystemIcons.changedLoggedInMenuState(false);
		}  // logoutHandler
		
		private static function settingsHandler(event:Event = null):void
		{
			controller.openSettingsWindow();
		}  // settingsHandler
		
		private static function pausePlayHandler(event:Event = null):void
		{
			if (pausePlayCommand.label == ResourceManager.getInstance().getString("resources", "contextMenu.pause"))
			{
				log.info("Pausing notifications");
				changeIcon(false);
				model.paused = true;
				pausePlayCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.resume");
			}  // if statement
			else
			{
				log.info("Resuming notifications");
				changeIcon(true);
				model.paused = false;
				pausePlayCommand.label = ResourceManager.getInstance().getString("resources", "contextMenu.pause");
			}  // else statement
		}  // pausePlayHandler
		
		private static function checkForUpdatesHandler(event:Event = null):void
		{
			log.info("Forcing a check for updates");
			
			var totalUpdates:int = 0;
			
			// news feed updates
			var getNewsFeedCommand:GetNewsFeed = new GetNewsFeed();
			getNewsFeedCommand.execute({since:model.latestNewsFeedUpdate}, getNewsFeedHandler);
			
			// TODO: incorporate preferences in this
			function getNewsFeedHandler(result:Object, fail:Object, passThroughArgs:Object = null):void
			{
				if (fail == null && result != null && result is Array && (result as Array).length > 0)
				{
					totalUpdates += (result as Array).length;
				}  // if statement
				
				// likes, comments, and group posts
				var getNotificationsCommand:GetNotifications = new GetNotifications();
				getNotificationsCommand.execute({since:model.latestNotificationUpdate}, getNotificationsHandler);
			}  // getNewsFeedHandler
			
			function getNotificationsHandler(result:Object, fail:Object, passThroughArgs:Object = null):void
			{
				if (fail == null && result != null && result is Array && (result as Array).length > 0)
				{
					totalUpdates += (result as Array).length;
				}  // if statement
				
				// messages, pokes, shares, friend-requests, group-invites, and event-invites
				var getAdditionalNotificationsCommand:GetAdditionalNotifications = new GetAdditionalNotifications();
				getAdditionalNotificationsCommand.execute(null, getAdditionalNotificationsHandler);
			}  // getNotificationsHandler
			
			function getAdditionalNotificationsHandler(result:Object, fail:Object, passThroughArgs:Object = null):void
			{
				if (fail == null && result != null)
				{
					// Note: We are ignoring event invites, friend requests, and group invites because of the
					//       way they are returned from the Facebook REST APIs.  They only return a count, which
					//       doesn't tell us if there are any *new* event invites, friend requests, or group
					//       invites.  Hopefully, they fix this when they convert this to the Graph APIs.
					
					// messages
					if (model.preferences.showMessages && result.messages != null && result.messages.most_recent > model.latestMessageUpdate)
					{
						totalUpdates += result.messages.unread;
					}  // if statement
					
					// pokes
					if (model.preferences.showPokes && result.pokes != null && result.pokes.most_recent > model.latestPokeUpdate)
					{
						totalUpdates += result.pokes.unread;
					}  // if statement
					
					// shares
					if (model.preferences.showShares && result.shares != null && result.shares.most_recent > model.latestShareUpdate)
					{
						totalUpdates += result.shares.unread;
					}  // if statement
					
					// if there were no updates, let the user know we checked
					if (totalUpdates == 0)
					{
						log.info("No new updates to show");
						notificationManager.show(ResourceManager.getInstance().getString("resources", "toast.noNewUpdates"), "", "/assets/images/toast/icon50.png", null, false, false, false);
					}  // if statement
				}  // if statement
			}  // getAdditionalNotificationsHandler
		}  // checkForUpdatesHandler
		
		private static function replayLatestFiveUpdatesHandler(event:Event = null):void
		{
			log.info("Displaying latest 5 updates");
			notificationManager.replayLatestFiveUpdates();
		}  // replayLatestFiveUpdatesHandler
		
		private static function exitHandler(event:Event = null):void
		{
			log.info("Exiting the application.");
			NativeApplication.nativeApplication.exit();
		}  // exitHandler
		
		private static function eventInvitesHandler(event:Event):void
		{
			log.info("Context menu click - viewing event invites");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_EVENT_INVITES_URL));
		}  // eventInvitesHandler
		
		private static function friendRequestsHandler(event:Event):void
		{
			log.info("Context menu click - viewing friend requests");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_FRIEND_REQUESTS_URL));
		}  // friendRequestsHandler
		
		private static function groupInvitesHandler(event:Event):void
		{
			log.info("Context menu click - viewing group invites");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_GROUP_INVITES_URL));
		}  // groupInvitesHandler
		
		private static function unreadMessagesHandler(event:Event):void
		{
			log.info("Context menu click - viewing unread messages");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_MESSAGES_URL));
		}  // unreadMessagesHandler
		
		private static function newPokesHandler(event:Event):void
		{
			log.info("Context menu click - viewing new pokes");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_POKES_URL));
		}  // newPokesHandler
		
		private static function newSharesHandler(event:Event):void
		{
			log.info("Context menu click - viewing new shares");
			flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_SHARES_URL));
		}  // newSharesHandler
	}  // class declaration
}  // package