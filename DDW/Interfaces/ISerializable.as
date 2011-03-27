package DDW.Interfaces
{
	public interface ISerializable
	{
		function serialize():Object;
		function deserialize(o:Object):void;
	}
}