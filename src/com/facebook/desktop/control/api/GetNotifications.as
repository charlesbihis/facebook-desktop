package com.facebook.desktop.control.api
{
	import com.charlesbihis.engine.notification.NotificationManager;
	import com.charlesbihis.engine.notification.ui.Notification;
	import com.facebook.desktop.control.util.Util;
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;

	public class GetNotifications implements ICommand
	{
		private static const API:String = "/me/notifications";
		
		private static var model:Model = Model.instance;
		private static var notificationManager:NotificationManager = NotificationManager.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetNotifications");
		
		private var args:Object;
		
		public function execute(args:Object = null, callback:Function = null, passThroughArgs:Object = null):void
		{
			if (model.preferences.showActivityUpdates)
			{
				FacebookDesktop.api(API, getNotificationsHandler, args);
			}  // if statement
			
			function getNotificationsHandler(result:Object, fail:Object):void
			{
				var notificationIds:Array = new Array();
				if (fail == null)
				{
					if (result != null && result is Array && (result as Array).length > 0)
					{
						var notifications:Array = result as Array;
						
						// update model
						var latestNotificationUpdate:Date = Util.RFC3339toDate(notifications[0].created_time);
						log.info("Setting latest notification time to " + latestNotificationUpdate.toString());
						model.latestNotificationUpdate = (latestNotificationUpdate.time / 1000).toString();
						
						// get application objects so we can use the icons in the notification window
						for (var i:int = 0; i < notifications.length; i++)
						{
							var getApplicationCommand:GetApplication = new GetApplication();
							getApplicationCommand.execute(notifications[i].application.id, getApplicationHandler, notifications[i]);
							
							// if user prefers to mark notifications as read, let's keep track of the notification IDs
							if (model.preferences.markNotificationsAsRead)
							{
								notificationIds.push(notifications[i].id);
							}  // if statement
						}  // for loop
					}  // if statement
				}  // if statement
				else
				{
					log.error("Request to get latest notifications has failed!  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
				
				// mark all as read
				if (model.preferences.markNotificationsAsRead)
				{
					log.info("Marking notifications as read");
					var markNotificationsRead:MarkNotificationsRead = new MarkNotificationsRead();
					markNotificationsRead.execute({notification_ids:notificationIds.toString()});
				} // if statement
				
				// make sure we call the callback
				if (callback != null && callback is Function)
				{
					callback(result, fail, passThroughArgs);
				}  // if statement
			}  // getNotificationsHandler
			
			function getApplicationHandler(result:Object, fail:Object, passThrough:Object):void
			{
				// show notification
				log.info("Notification update! - " + passThrough.title);

				var notification:Notification = new Notification();
				notification.notificationTitle = passThrough.title;
				notification.notificationMessage = "";
				notification.notificationImage = result.icon_url;
				notification.notificationLink = passThrough.link;
				notification.isCompact = true;
				notificationManager.showNotification(notification);
			}  // getApplicationHandler
		}  // execute
	}  // class declaration
}  // package