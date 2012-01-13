package com.facebook.desktop.model.cache
{
	public class UserCache implements ICache
	{
		private static var _instance:UserCache = new UserCache(SingletonLock);
		
		private var cache:Object;
		
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
		
		public function get(key:String):Object
		{
			return cache[key];
		}  // get
		
		public function put(key:String, value:Object):void
		{
			cache[key] = value;
		}  // put
		
		public function contains(key:String):Boolean
		{
			return cache[key] != null;
		}  // contains
	}  // class declaration
}  // package

class SingletonLock {}