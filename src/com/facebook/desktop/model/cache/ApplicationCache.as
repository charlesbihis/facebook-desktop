package com.facebook.desktop.model.cache
{
	public class ApplicationCache implements ICache
	{
		private static var _instance:ApplicationCache = new ApplicationCache(SingletonLock);
		
		private var cache:Object;
		
		public function ApplicationCache(lock:Class)
		{
			if (lock != SingletonLock)
			{
				throw new Error("Invalid singleton access.  Use ApplicationCache.instance instead.");
			}  // if statement
			
			cache = new Object();
		}  // ApplicationCache
		
		public static function get instance():ApplicationCache
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