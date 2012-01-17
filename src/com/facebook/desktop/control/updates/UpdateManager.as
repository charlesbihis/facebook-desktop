package com.facebook.desktop.control.updates
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.UpdateEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class UpdateManager
	{
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.updates.UpdateManager");
		
		public static function checkForUpdates():void
		{
			var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
			appUpdater.configurationFile = new File("app:/Main-update.xml");
			appUpdater.isCheckForUpdateVisible = false;
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdaterInitialized);
			appUpdater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onDownloadError);
			appUpdater.addEventListener(ErrorEvent.ERROR, onError);
			appUpdater.addEventListener(StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, onStatusFileUpdateError);
			appUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onStatusUpdateError);
			appUpdater.initialize();
			
			// Delaying call to checkNow() by 100ms because of bug in ApplicationUpdaterUI in Flex 3.2
			function onUpdaterInitialized(event:Event):void
			{
				setTimeout(delayedUpdaterInitialized, 100, UpdateEvent(event));
			}  // onUpdaterInitialized
			
			function delayedUpdaterInitialized(event:Event):void
			{
				logger.info("Checking for updates now");
				appUpdater.checkNow();
			}  // delayedUpdaterInitialized
			
			function onDownloadError(event:Event):void
			{
				logger.error("Error downloading update file");
			}  // onDownloadError
			
			function onError(event:Event):void
			{
				logger.error("Error updating the application");
			}  // onError
			
			function onStatusFileUpdateError(event:Event):void
			{
				logger.error("Error while downloading or parsing the update descriptor file (air.update.events.StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR)");
			}  // onStatusFileUpdateError
			
			function onStatusUpdateError(event:Event):void
			{
				logger.error("Error while downloading or parsing the update descriptor file (air.update.events.StatusUpdateErrorEvent.UPDATE_ERROR)");
			}  // onStatusUpdateError
		}  // checkForUpdates
	}  // class declaration
}  // package