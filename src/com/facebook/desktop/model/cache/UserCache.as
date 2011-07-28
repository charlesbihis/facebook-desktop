package com.facebook.desktop.model.cache
{
	public class UserCache
	{
		public var cache:Object;
		
		private static var _instance:UserCache = new UserCache(SingletonLock);
		
		public function UserCache(lock:Class)
		{
			if (lock != SingletonLock)
			{
				throw new Error("Invalid singleton access.  Use UserCache.instance instead.");
			}  // if statement
			
			cache = new Object();
		}  // UserCache
		
		public static function get instance():UserCache
		{
			return _instance;
		}  // instance
	}  // class declaration
}  // package

class SingletonLock {}