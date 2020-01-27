import java.io.FileInputStream;
import java.sql.*;
import java.util.Properties;

/**
 * Runs queries against a back-end database.
 * This class is responsible for searching for flights.
 */
public class QuerySearchOnly
{
    // `dbconn.properties` config file
    private String configFilename;

    // DB Connection
    protected Connection conn;

    // Canned queries
    protected PreparedStatement directOnlyStmt;
    protected PreparedStatement indirectOkStmt;

    protected PreparedStatement insertSearchStatementDirect;
    protected PreparedStatement insertSearchStatementIndirect;

    protected PreparedStatement deleteItinerariesStatement;

    class Flight
    {
        public int fid;
        public int dayOfMonth;
        public String carrierId;
        public String flightNum;
        public String originCity;
        public String destCity;
        public int time;
        public int capacity;
        public int price;

        public Flight(int fid, int dayOfMonth, String carrierId, String flightNum, String originCity,
                      String destCity, int time, int capacity, int price) {
            this.fid = fid;
            this.dayOfMonth = dayOfMonth;
            this.carrierId = carrierId;
            this.flightNum = flightNum;
            this.originCity = originCity;
            this.destCity = destCity;
            this.time = time;
            this.capacity = capacity;
            this.price = price;
        }

        @Override
        public String toString()
        {
            return "ID: " + fid + " Day: " + dayOfMonth + " Carrier: " + carrierId +
                    " Number: " + flightNum + " Origin: " + originCity + " Dest: " + destCity + " Duration: " + time +
                    " Capacity: " + capacity + " Price: " + price;
        }
    }

    public QuerySearchOnly(String configFilename)
    {
        this.configFilename = configFilename;
    }

    /** Open a connection to SQL Server in Microsoft Azure.  */
    public void openConnection() throws Exception
    {
        Properties configProps = new Properties();
        configProps.load(new FileInputStream(configFilename));

        String jSQLDriver = configProps.getProperty("flightservice.jdbc_driver");
        String jSQLUrl = configProps.getProperty("flightservice.url");
        String jSQLUser = configProps.getProperty("flightservice.sqlazure_username");
        String jSQLPassword = configProps.getProperty("flightservice.sqlazure_password");

        /* load jdbc drivers */
        Class.forName(jSQLDriver).newInstance();

        /* open connections to the flights database */
        conn = DriverManager.getConnection(jSQLUrl, // database
                jSQLUser, // user
                jSQLPassword); // password

        conn.setAutoCommit(true); //by default automatically commit after each statement
		/* In the full Query class, you will also want to appropriately set the transaction's isolation level:
		conn.setTransactionIsolation(...)
		See Connection class's JavaDoc for details.
		*/
    }

    public void closeConnection() throws Exception
    {
        conn.close();
    }

    /**
     * prepare all the SQL statements in this method.
     * "preparing" a statement is almost like compiling it.
     * Note that the parameters (with ?) are still not filled in
     */
    public void prepareStatements() throws Exception
    {

        /* add here more prepare statements for all the other queries you need */
        /* . . . . . . */
        deleteItinerariesStatement = conn.prepareStatement("DELETE FROM Itineraries");

        String directOnly = "SELECT TOP (?) fid, day_of_month, carrier_id, flight_num, " +
                "origin_city, " +
                "dest_city, actual_time, capacity, price " +
                "FROM Flights " +
                "WHERE canceled = 0 " +
                "AND origin_city = (?) " +
                "AND dest_city = (?) " +
                "AND day_of_month = (?) " +
                "ORDER BY actual_time, fid";
        directOnlyStmt = conn.prepareStatement(directOnly);

        String indirectOk = "SELECT TOP (?) * \n" +
                "FROM (SELECT TOP (?) a.fid a_fid,\n" +
                "a.day_of_month a_day_of_month,\n" +
                "a.carrier_id a_carrier_id,\n" +
                "a.flight_num a_flight_num,\n" +
                "a.origin_city a_origin_city,\n" +
                "a.dest_city a_dest_city,\n" +
                "a.actual_time a_actual_time,\n" +
                "a.capacity a_capacity,\n" +
                "a.price a_price,\n" +
                "b.fid b_fid,\n" +
                "b.day_of_month b_day_of_month,\n" +
                "b.carrier_id b_carrier_id,\n" +
                "b.flight_num b_flight_num,\n" +
                "b.origin_city b_origin_city,\n" +
                "b.dest_city b_dest_city,\n" +
                "b.actual_time b_actual_time,\n" +
                "b.capacity b_capacity,\n" +
                "b.price b_price,\n" +
                "a.actual_time + b.actual_time combined_time\n" +
                "FROM Flights a, Flights b \n" +
                "WHERE a.canceled = 0 AND b.canceled = 0\n" +
                "AND a.day_of_month = b.day_of_month\n" +
                "AND a.origin_city = ? AND b.dest_city = ? AND a.day_of_month = ?\n" +
                "AND a.dest_city = b.origin_city \n" +
                "ORDER BY combined_time \n" +
                "UNION\n" +
                "SELECT TOP (?) fid a_fid, \n" +
                "day_of_month a_day_of_month, \n" +
                "carrier_id a_carrier_id, \n" +
                "flight_num a_flight_num, \n" +
                "origin_city a_origin_city,\n" +
                "dest_city a_dest_city, \n" +
                "actual_time a_actual_time, \n" +
                "capacity a_capacity, \n" +
                "price a_price,\n" +
                "NULL b_fid,\n" +
                "NULL b_day_of_month,\n" +
                "NULL b_carrier_id,\n" +
                "NULL b_flight_num,\n" +
                "NULL b_origin_city,\n" +
                "NULL b_dest_city,\n" +
                "NULL b_actual_time,\n" +
                "NULL b_capacity,\n" +
                "NULL b_price,\n" +
                "actual_time combined_time\n" +
                "FROM Flights\n" +
                "WHERE canceled = 0 \n" +
                "AND origin_city = ?\n" +
                "AND dest_city = ?\n" +
                "AND day_of_month = ? " +
                "ORDER BY combined_time) f \n" +
                "ORDER BY combined_time";

        indirectOkStmt = conn.prepareStatement(indirectOk);

        insertSearchStatementIndirect = conn.prepareStatement("INSERT " +
                "INTO Itineraries (iid, flight1, flight2) " +
                "VALUES ((?), (?), (?))");

        insertSearchStatementDirect = conn.prepareStatement("INSERT " +
                "INTO Itineraries (iid, flight1) " +
                "VALUES ((?), (?))");
    }



    /**
     * Implement the search function.
     *
     * Searches for flights from the given origin city to the given destination
     * city, on the given day of the month. If {@code directFlight} is true, it only
     * searches for direct flights, otherwise it searches for direct flights
     * and flights with two "hops." Only searches for up to the number of
     * itineraries given by {@code numberOfItineraries}.
     *
     * The results are sorted based on total flight time.
     *
     * @param originCity
     * @param destinationCity
     * @param directFlight if true, then only search for direct flights, otherwise include indirect flights as well
     * @param dayOfMonth
     * @param numberOfItineraries number of itineraries to return
     *
     * @return If no itineraries were found, return "No flights match your selection\n".
     * If an error occurs, then return "Failed to search\n".
     *
     * Otherwise, the sorted itineraries printed in the following format:
     *
     * Itinerary [itinerary number]: [number of flights] flight(s), [total flight time] minutes\n
     * [first flight in itinerary]\n
     * ...
     * [last flight in itinerary]\n
     *
     * Each flight should be printed using the same format as in the {@code Flight} class. Itinerary numbers
     * in each search should always start from 0 and increase by 1.
     *
     * @see Flight#toString()
     */
    public String transaction_search(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                     int numberOfItineraries)
    {
        // Please implement your own (safe) version that uses prepared statements rather than string concatenation.
        // You may use the `Flight` class (defined above).
        return transaction_search_safe(originCity, destinationCity, directFlight, dayOfMonth,
                numberOfItineraries);
    }

    private String transaction_search_safe (String originCity, String destinationCity,
                                            boolean directFlight, int dayOfMonth,
                                            int numberOfItineraries) {

        StringBuffer sb = new StringBuffer();
        try {

            int index = 0;
            deleteItinerariesStatement.execute();

            if (directFlight) {
                directOnlyStmt.clearParameters();
                directOnlyStmt.setInt(1, numberOfItineraries);
                directOnlyStmt.setString(2, originCity);
                directOnlyStmt.setString(3, destinationCity);
                directOnlyStmt.setInt(4, dayOfMonth);

                ResultSet directResults = directOnlyStmt.executeQuery();

                while (directResults.next()) {
                    Flight flight = new Flight(directResults.getInt("fid"),
                            directResults.getInt("day_of_month"),
                            directResults.getString("carrier_id"),
                            directResults.getString("flight_num"),
                            directResults.getString("origin_city"),
                            directResults.getString("dest_city"),
                            directResults.getInt("actual_time"),
                            directResults.getInt("capacity"),
                            directResults.getInt("price"));

                    sb.append("Itinerary " + index + ": ")
                            .append("1 flight(s), ")
                            .append(directResults.getInt("actual_time") + " minutes")
                            .append('\n')
                            .append(flight.toString()).append('\n');

                    insertSearchStatementDirect.clearParameters();
                    insertSearchStatementDirect.setInt(1, index);
                    insertSearchStatementDirect.setInt(2, flight.fid);
                    insertSearchStatementDirect.execute();

                    index++;
                }
                directResults.close();
            } else {
                indirectOkStmt.clearParameters();
                indirectOkStmt.setInt(1, numberOfItineraries);
                indirectOkStmt.setInt(2, numberOfItineraries);
                indirectOkStmt.setString(3, originCity);
                indirectOkStmt.setString(4, destinationCity);
                indirectOkStmt.setInt(5, dayOfMonth);
                indirectOkStmt.setInt(6, numberOfItineraries);
                indirectOkStmt.setString(7, originCity);
                indirectOkStmt.setString(8, destinationCity);
                indirectOkStmt.setInt(9, dayOfMonth);

                ResultSet indirectResults = indirectOkStmt.executeQuery();
                while (indirectResults.next()) {
                    int numFlights = 1;
                    Flight flight1 = new Flight(indirectResults.getInt("a_fid"),
                            indirectResults.getInt("a_day_of_month"),
                            indirectResults.getString("a_carrier_id"),
                            indirectResults.getString("a_flight_num"),
                            indirectResults.getString("a_origin_city"),
                            indirectResults.getString("a_dest_city"),
                            indirectResults.getInt("a_actual_time"),
                            indirectResults.getInt("a_capacity"),
                            indirectResults.getInt("a_price"));

                    Flight flight2 = new Flight(indirectResults.getInt("b_fid"),
                            indirectResults.getInt("b_day_of_month"),
                            indirectResults.getString("b_carrier_id"),
                            indirectResults.getString("b_flight_num"),
                            indirectResults.getString("b_origin_city"),
                            indirectResults.getString("b_dest_city"),
                            indirectResults.getInt("b_actual_time"),
                            indirectResults.getInt("b_capacity"),
                            indirectResults.getInt("b_price"));

                    String flight2Str;
                    if (indirectResults.getInt("b_fid") == 0) {
                        flight2Str = "";
                    } else {
                        flight2Str = flight2.toString();
                        numFlights++;
                    }

                    sb.append("Itinerary " + index + ": ")
                            .append("" + numFlights).append(" flight(s), ")
                            .append((indirectResults.getInt("a_actual_time") +
                                    indirectResults.getInt("b_actual_time")) + " minutes")
                            .append('\n')
                            .append(flight1.toString()).append('\n')
                            .append(flight2Str);



                    if (indirectResults.getInt("b_fid") != 0) {
                        sb.append('\n');
                        insertSearchStatementIndirect.clearParameters();
                        insertSearchStatementIndirect.setInt(1, index);
                        insertSearchStatementIndirect.setInt(2, flight1.fid);
                        insertSearchStatementIndirect.setInt(3, flight2.fid);
                        insertSearchStatementIndirect.execute();
                    } else {
                        insertSearchStatementDirect.clearParameters();
                        insertSearchStatementDirect.setInt(1, index);
                        insertSearchStatementDirect.setInt(2, flight1.fid);
                        insertSearchStatementDirect.execute();
                    }

                    index++;
                }
            }

            if (index == 0) return "No flights match your selection\n";

        } catch (SQLException e) {
            e.printStackTrace();
            return "Failed to search\n";
        }

        return sb.toString();
    }
}
