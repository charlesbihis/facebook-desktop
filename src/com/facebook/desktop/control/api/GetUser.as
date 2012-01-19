package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.cache.UserCache;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetUser implements ICommand
	{
		public var userId:String;
		
		private static var userCache:UserCache = UserCache.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetUser");
		
		public function GetUser(userId:String = null)
		{
			this.userId = userId;
		}  // GetUser
		
		public function execute(args:Object = null, callback:Function = null, passThroughVariables:Object = null):void
		{
			log.info("Retrieving user object with ID " + userId);
			
			if (userId != null)
			{
				if (userCache.contains(userId))
				{
					log.info("User object with ID " + userId + " found in user cache.  Returning cached object instead.");
					callback(userCache.get(userId), passThroughVariables);
				}  // if statement
				else
				{
					var getObjectCommand:GetObject = new GetObject();
					getObjectCommand.execute(userId, getObjectHandler);
				}  // else statement
			}  // if statement
			else
			{
				log.error("Error fetching user.  User ID is null.");
			}  // else statement
			
			function getObjectHandler(result:Object, fail:Object, passThroughArgs:Object):void
			{
				if (callback != null && callback is Function)
				{
					log.info("Placing user object with ID " + userId + " in user cache");
					userCache.put(userId, result);
					callback(result, fail, passThroughVariables);
				}  // if statement
			}  // getObjectHandler
		}  // execute
	}  // class declaration
}  // package