package de.gurkinator;

import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Main {
    public static void main(String[] args) throws SQLException, IOException {
        Connection con;
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite::memory:")) {
            try (InputStream is = Main.class.getClassLoader().getResourceAsStream("init.sql")) {
                assert is != null;
                var init = new String(is.readAllBytes(), StandardCharsets.UTF_8);

                connection.nativeSQL(init);
                con = connection;
            }
        }
        catch (SQLException | IOException e) {
            System.out.println("failed to open temporary database!");
            e.printStackTrace();
            return;
        }

        System.out.print("DB setup complete!");

        HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
        server.createContext("/api", new WebHandler());
        server.setExecutor(null);
        server.start();


        //TODO
        con.close();
    }
}