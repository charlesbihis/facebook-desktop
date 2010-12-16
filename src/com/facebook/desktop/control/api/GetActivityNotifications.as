package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	import com.facebook.desktop.control.notification.ToastManager;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetActivityNotifications
	{
		private static const API_CALL:String = "notifications.getList";
		
		private static var model:Model = Model.instance;
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetActivityNotifications");
		
		public var startTime:String;
		public var includeRead:String;
		
		public function execute(callback:Function = null):void
		{
			var args:Object = new Object();
			if (includeRead != null && includeRead.length > 0)
			{
				args.include_read = includeRead;
			}
			if (startTime != null && startTime.length > 0)
			{
				args.start_time = startTime;
			}  // if statement
			
			FacebookDesktop.callRestAPI(API_CALL, handler, args);
			
			function handler(result:Object, fail:Object):void
			{
				if (result)
				{
					if (model.preferences.showStoryActivity && result.notifications && result.notifications.length > 0 && result.apps && result.apps.length > 0)
					{
						var notificationIds:Array = new Array();
						for (var i:int = 0; i < result.notifications.length; i++)
						{
							notificationIds.push(result.notifications[i].notification_id.toString());
							
							var notification:Object = result.notifications[i];
							var appId:String = notification.app_id;
							var appIconUrl:String;
							
							for (var j:int = 0; j < result.apps.length; j++)
							{
								var app:Object = result.apps[j];
								
								if (app.app_id == appId)
								{
									appIconUrl = app.icon_url;
									break;
								}  // if statement
							}  // for loop
							
							logger.info("Notifications-list update! - {0}: {1}", notification.title_text, notification.body_html);
							ToastManager.queueToast(notification.title_text, notification.body_html, notification.href, appIconUrl, true);
						}  // for loop
						ToastManager.showAll();
						
						// mark all as read
						if (model.preferences.markNotificationsAsRead)
						{
							logger.info("Marking notifications as read");
							var markNotificationsRead:MarkNotificationsRead = new MarkNotificationsRead();
							markNotificationsRead.notificationIds = notificationIds.toString();
							markNotificationsRead.execute();
						}  // if statement
						
						model.latestActivityUpdate = result.notifications[0].created_time;
					}  // if statement
				}  // if statement
				else
				{
					logger.error("Error fetching notifications!  Error: " + fail);
				}  // else statement
				
				if (callback != null)
				{
					callback(result, fail);
				}  // if statement
			}  // handler
		}  // execute
	}
}