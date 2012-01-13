package com.facebook.desktop.control.api
{
	import com.facebook.desktop.model.Model;
	import com.facebook.graph.FacebookDesktop;
	import com.facebook.desktop.model.cache.UserCache;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class GetUserInfo
	{
		private static const API_CALL:String = "users.getInfo";
		
		private static var model:Model = Model.instance;
		private static var logger:ILogger = Log.getLogger("com.facebook.desktop.control.api.GetUserInfo");
		
		private var userCache:UserCache = UserCache.instance;
		
		public var uids:String;
		public var fields:String;
		
		public function execute(callback:Function = null):void
		{
			var allInCache:Boolean = true;
			var results:Array = uids.split(',');
			for (var i:int = 0; i < results.length; i++)
			{
				var uid:String = results[i];
				if (!userCache.get(uid))
				{
					allInCache = false;
				}  // if statement
			}  // for loop
			
			// they're not all in the cache, so might as well get them all
			if (allInCache)
			{
				if (callback != null)
				{
					callback();
				}  // if statement
			}  // if statement
			else
			{
				var args:Object = new Object();
				args.fields = fields;
				args.uids = uids;
				
				FacebookDesktop.callRestAPI(API_CALL, handler, args);
			}  // else statement
			
			function handler(result:Object, fail:Object):void
			{
				if (result is Array && (result as Array).length > 0)
				{
					var users:Array = result as Array;
					for (var i:int = 0; i < users.length; i++)
					{
						var user:Object = users[i];
						
						logger.info("Placing " + user.name + "(" + user.uid + ") into the user-cache");
						userCache.put(user.uid, user);
					}  // for loop
				}  // if statement
				
				if (callback != null)
				{
					callback(result, fail);
				}  // if statement
			}  // handler
		}  // execute
	}  // class declaration
}  // package