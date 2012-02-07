package com.facebook.desktop.control.api
{
	import com.charlesbihis.engine.notification.NotificationManager;
	import com.charlesbihis.engine.notification.ui.Notification;
	import com.facebook.desktop.FacebookDesktopConst;
	import com.facebook.desktop.control.util.Util;
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;

	public class GetNewsFeed implements ICommand
	{
		private static const API:String = "/me/home";
		
		private static var model:Model = Model.instance;
		private static var notificationManager:NotificationManager = NotificationManager.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetNewsFeed");
		
		private var args:Object;
		
		public function execute(args:Object = null, callback:Function = null, passThroughArgs:Object = null):void
		{
			if (model.preferences.showNewsFeedUpdates)
			{
				FacebookDesktop.api(API, getNewsFeedHandler, args);
			}  // if statement
			
			function getNewsFeedHandler(result:Object, fail:Object):void
			{
				if (fail == null)
				{
					if (result != null && result is Array && (result as Array).length > 0)
					{
						var newsFeedUpdates:Array = result as Array;
						
						// update model
						var latestNewsFeedUpdate:Date = Util.RFC3339toDate(result[0].created_time);
						log.info("Setting latest news feed update time to " + (latestNewsFeedUpdate.time / 1000));
						model.latestNewsFeedUpdate = (latestNewsFeedUpdate.time / 1000).toString();
						
						// display notifications
						var story:Object;
						for (var i:int = 0; i < newsFeedUpdates.length; i++)
						{
							story = newsFeedUpdates[i];
							
							// build title string
							var titleString:String = story.from.name;
							if (story.to != null && story.to.data != null && story.to.data is Array && (story.to.data as Array).length > 0 && story.to.data[0] != null && story.to.data[0].name is String && (story.to.data[0].name as String).length > 0)
							{
								titleString += " ► " + story.to.data[0].name;
							}  // if statement
							
							// build message string
							var messageString:String;
							switch (story.type)
							{
								case "checkin":
									if (story.message != null && story.message is String && (story.message as String).length > 0)
									{
										messageString = story.message;
									}  // if statement
									else
									{
										messageString = "has posted a photo to Facebook";
									}  // else statement
									break;
								case "link":
									if (story.story != null && story.story is String && (story.story as String).length > 0)
									{
										messageString = story.story;
									}  // if statement
									else if (story.message != null && story.message is String && (story.message as String).length > 0)
									{
										messageString = story.message;
									}  // else-if statement
									else
									{
										messageString = "has posted a link to Facebook";
									}  // else statement
									break;
								case "photo":
									if (story.message != null && story.message is String && (story.message as String).length > 0)
									{
										messageString = story.message;
									}  // if statement
									else
									{
										messageString = "has posted a photo to Facebook";
									}  // else statement
									break;
								case "status":
									if (story.message != null && story.message is String && (story.message as String).length > 0)
									{
										messageString = story.message;
									}  // if statement
									else
									{
										messageString = "has posted a story to Facebook";
									}  // else statement
									break;
								case "video":
									if (story.message != null && story.message is String && (story.message as String).length > 0)
									{
										messageString = story.message;
									}  // if statement
									else
									{
										messageString = "has posted a video to Facebook";
									}  // else statement
									break;
								default:
									messageString = "has posted a story to Facebook";
									break;
							}  // switch statement
							
							// build link string
							var linkString:String;
							switch (story.type)
							{
								case "photo":
									linkString = story.link;
									break;
								case "checkin":
								case "link":
								case "status":
								case "video":
								default:
									linkString = story.actions[0].link;
									break;
							}  // switch statement
							
							// show it
							var notification:Notification = new Notification();
							notification.notificationTitle = titleString;
							notification.notificationMessage = messageString;
							notification.notificationImage = FacebookDesktopConst.FACEBOOK_GRAPH_API_ENDPOINT + story.from.id + "/picture";
							notification.notificationLink = linkString;
							notification.isSticky = model.preferences.showNewsFeedUpdatesSticky;
							notificationManager.showNotification(notification);
							
							// play sound
							if (model.preferences.playNotificationSound && (new Date().time - model.latestNotificationSound > Model.MINIMUM_TIME_BETWEEN_NOTIFICATION_SOUNDS))
							{
								model.notificationSound.play();
								model.latestNotificationSound = new Date().time;
							}  // if statement
						}  // for loop
					}  // if statement
				}  // if statement
				else
				{
					log.error("Request to get latest news feed updates has failed!  Error object: " + ObjectUtil.toString(fail));
				}  // else statement
				
				// make sure we call the callback
				if (callback != null && callback is Function)
				{
					callback(result, fail, passThroughArgs);
				}  // if statement
			}  // getNewsFeedHandler
		}  // execute
	}  // class declaration
}  // package