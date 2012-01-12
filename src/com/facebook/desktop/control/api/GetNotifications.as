package com.facebook.desktop.control.api
{
	import com.facebook.desktop.control.notification.ToastManager;
	import com.facebook.desktop.control.util.Util;
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;

	public class GetNotifications
	{
		private static const API:String = "/me/notifications";
		
		private static var model:Model = Model.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetNotifications");
		
		private var args:Object;
		
		public function GetNotifications(args:Object = null)
		{
			this.args = args;
		}  // GetNotifications
		
		public function execute(callback:Function = null):void
		{
			// configure arguments
			if (args == null)
			{
				args = new Object();
			}  // if statement
			if (args.since == null && model.latestNotificationUpdate != null)
			{
				args.since = model.latestNotificationUpdate;
			}  // if statement
			
			FacebookDesktop.api(API, getNotificationsHandler, args);
			
			function getNotificationsHandler(result:Object, fail:Object):void
			{
				if (!fail && result is Array && (result as Array).length > 0)
				{
					var notifications:Array = result as Array;
					var latestNotificationUpdate:Date = Util.RFC3339toDate(notifications[0].created_time);
					log.info("Setting latest notification time to " + latestNotificationUpdate.toString());
					model.latestNotificationUpdate = (latestNotificationUpdate.time / 1000).toString();
					
					for (var i:int = 0; i < notifications.length; i++)
					{
						var getApplicationCommand:GetApplication = new GetApplication(notifications[i].application.id);
						getApplicationCommand.execute(getApplicationHandler, notifications[i]);
					}  // for loop
				}  // if statement
				else
				{
					log.error("Request to get latest notifications has failed!  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
			}  // getNotificationsHandler
			
			function getApplicationHandler(application:Object, notification:Object):void
			{
				log.info("Notification update! - " + notification.title);
				ToastManager.queueToast(notification.title, "", notification.link, application.icon_url, true);
				ToastManager.showAll();
			}  // getApplicationHandler
		}  // execute
	}  // class declaration
}  // package