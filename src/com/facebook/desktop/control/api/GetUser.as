package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.cache.UserCache;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetUser
	{
		public var userId:String;
		
		private static var userCache:UserCache = UserCache.instance;
		private static var log:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetUser");
		
		public function GetUser(userId:String = null)
		{
			this.userId = userId;
		}  // GetUser
		
		public function execute(callback:Function = null, passThroughVariables:Object = null):void
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
					var getObjectCommand:GetObject = new GetObject(userId);
					getObjectCommand.execute(getObjectHandler);
				}  // else statement
			}  // if statement
			else
			{
				throw new Error("Error fetching user.  User ID is null.");
			}  // else statement
			
			function getObjectHandler(result:Object):void
			{
				if (callback != null)
				{
					log.info("Placing user object with ID " + userId + " in user cache");
					userCache.put(userId, result);
					callback(result, passThroughVariables);
				}  // if statement
			}  // getObjectHandler
		}  // execute
	}  // class declaration
}  // package