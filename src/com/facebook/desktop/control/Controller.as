package com.facebook.desktop.control
{
	import com.facebook.desktop.view.composer.Composer;
	import com.facebook.desktop.view.window.AboutWindow;
	import com.facebook.desktop.view.window.PreferencesWindow;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class Controller
	{
		private static var _instance:Controller = new Controller(SingletonLock);
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.Controller");
		
		public var aboutWindowOpen:Boolean;
		public var settingsWindowOpen:Boolean;
		public var statusUpdateWindowOpen:Boolean;
		
		private var aboutWindow:AboutWindow;
		private var settingsWindow:PreferencesWindow;
		private var statusUpdateWindow:Composer;


		public function Controller(lock:Class)
		{
			if (lock != SingletonLock)
			{
				throw new Error("Invalid singleton access.  User Controller.instance instead.");
			}  // if statement
		}  // Controller
		
		public static function get instance():Controller
		{
			return _instance;
		}  // instance
		
		public function openAboutWindow():void
		{
			if (!aboutWindowOpen)
			{
				logger.info("Displaying 'About' window");
				aboutWindow = new AboutWindow();
				aboutWindow.open(true);
				
				aboutWindowOpen = true;
			}  // if statement
			else
			{
				logger.info("'About' window already showing");
			}  // else statement
		}  // openAboutWindow
		
		public function openSettingsWindow():void
		{
			if (!settingsWindowOpen)
			{
				logger.info("Displaying 'Settings' window");
				settingsWindow = new PreferencesWindow();
				settingsWindow.open(true);
				
				settingsWindowOpen = true;
			}  // if statement
			else
			{
				logger.info("'Settings' window already showing");
			}  // else statement
		}  // openSettingsWindow
		
		public function openStatusUpdateWindow():void
		{
			if (!statusUpdateWindowOpen)
			{
				// make sure we only have one composer object
				if (statusUpdateWindow == null)
				{
					statusUpdateWindow = new Composer();
				}  // if statement
				
				statusUpdateWindow.open(true);
			}  // if statement
			else
			{
				logger.info("Status-update window already visible");
				statusUpdateWindow.hide();
			}  // else statement
		}  // openStatusUpdateWindow
	}  // class declaration
}  // package

class SingletonLock {}