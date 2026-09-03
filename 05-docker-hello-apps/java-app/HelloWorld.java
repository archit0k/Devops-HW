import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;

public class HelloWorld {
  public static void main(String[] args) throws Exception {
    HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
    server.createContext("/", exchange -> {
      byte[] body = "<h1>Hello World from Java!</h1>".getBytes();
      exchange.sendResponseHeaders(200, body.length);
      exchange.getResponseBody().write(body);
      exchange.close();
    });
    server.start();
  }
}
