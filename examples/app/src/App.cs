[assembly: log4net.Config.XmlConfigurator(ConfigFileExtension="log4net", Watch=true)]
namespace Examples {
   public class App {
      private static readonly log4net.ILog log =
         log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

      public static void Main(string[] args) {
         System.Console.WriteLine("Test");
         if (log.IsInfoEnabled) log.Info("Test");
      }
   }
}
