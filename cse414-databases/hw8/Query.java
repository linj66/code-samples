import java.sql.*;

public class Query extends QuerySearchOnly {

	// Logged In User
	private String username; // customer username is unique
	// private int rid = 0; // current reservation ID

	// transactions
	private static final String BEGIN_TRANSACTION_SQL = "SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; BEGIN TRANSACTION;";
	protected PreparedStatement beginTransactionStatement;

	private static final String COMMIT_SQL = "COMMIT TRANSACTION";
	protected PreparedStatement commitTransactionStatement;

	private static final String ROLLBACK_SQL = "ROLLBACK TRANSACTION";
	protected PreparedStatement rollbackTransactionStatement;

	// clearing tables
	protected PreparedStatement deleteUserStatement;
	protected PreparedStatement deleteItinerariesStatement;
	protected PreparedStatement deleteReservationsStatement;
	protected PreparedStatement dropReservationsStatement;
	protected PreparedStatement createReservationsStatement;

	// creating and logging in users
	protected PreparedStatement createUserStatement;
	protected PreparedStatement createLoginStatement;
	private boolean loggedIn = false;

	// booking statements
	protected PreparedStatement selectItineraryStatement;
	protected PreparedStatement insertReservationStatement1;
	protected PreparedStatement insertReservationStatement2;
	//protected PreparedStatement getCapacityStatement;
	//protected PreparedStatement decrementCapacityStatement;
	protected PreparedStatement getReservationStatement;
	protected PreparedStatement getRidStatement1;
	protected PreparedStatement getRidStatement2;

	// pay statements
	protected PreparedStatement getReservationPayStatement;
	protected PreparedStatement updateBalanceStatement;
	protected PreparedStatement updatePaidStatement;
	protected PreparedStatement getRsvPriceStatement;

	protected PreparedStatement getUserStatement;

	// reservation statements
    protected PreparedStatement getReservationFlightStatement;

	public Query(String configFilename) {
		super(configFilename);
	}


	/**
	 * Clear the data in any custom tables created. Do not drop any tables and do not
	 * clear the flights table. You should clear any tables you use to store reservations
	 * and reset the next reservation ID to be 1.
	 */
	public void clearTables()
	{
		// your code here
		try {

			dropReservationsStatement.execute();
			deleteItinerariesStatement.execute();
			deleteUserStatement.execute();
			createReservationsStatement.execute();

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}


	/**
	 * prepare all the SQL statements in this method.
	 * "preparing" a statement is almost like compiling it.
	 * Note that the parameters (with ?) are still not filled in
	 */
	@Override
	public void prepareStatements() throws Exception
	{
		super.prepareStatements();
		beginTransactionStatement = conn.prepareStatement(BEGIN_TRANSACTION_SQL);
		commitTransactionStatement = conn.prepareStatement(COMMIT_SQL);
		rollbackTransactionStatement = conn.prepareStatement(ROLLBACK_SQL);

		/* add here more prepare statements for all the other queries you need */
		/* . . . . . . */
		//deleteReservationsStatement = conn.prepareStatement("DELETE FROM Reservations");
		deleteItinerariesStatement = conn.prepareStatement("DELETE FROM Itineraries");
		deleteItinerariesStatement.execute();
		//deleteReservationsStatement.execute();
		deleteUserStatement = conn.prepareStatement("DELETE FROM Users");
		dropReservationsStatement = conn.prepareStatement("DROP TABLE Reservations");
		createReservationsStatement = conn.prepareStatement(
				"CREATE TABLE Reservations (\n" +
						"rid INTEGER PRIMARY KEY IDENTITY(1,1),\n" +
						"username VARCHAR(20) REFERENCES Users,\n" +
						"paid INTEGER, -- 0 or 1 -> unpaid or paid\n" +
						"day INTEGER,\n" +
						"flight1 INTEGER REFERENCES Flights,\n" +
						"flight2 INTEGER\n" +
						");"
		);

		createUserStatement = conn.prepareStatement(
				"INSERT INTO Users (username, password, balance) VALUES ((?), (?), (?))");

		createLoginStatement = conn.prepareStatement(
				"SELECT username, password, balance FROM Users " +
					"WHERE username = (?) AND password = (?)");

		selectItineraryStatement = conn.prepareStatement(
				"SELECT flight1, flight2, day_of_month FROM Itineraries, Flights " +
						"WHERE iid = (?) AND flight1 = fid");
		insertReservationStatement1 = conn.prepareStatement(
				"INSERT INTO Reservations (username, paid, day, flight1, flight2) " +
					"VALUES ((?), 0, (?), (?), (?))");
		insertReservationStatement2 = conn.prepareStatement(
				"INSERT INTO Reservations (username, paid, day, flight1) " +
						"VALUES ((?), 0, (?), (?))"
		);
		/*
		getCapacityStatement = conn.prepareStatement(
				"SELECT fid, capacity FROM Flights WHERE fid = (?) " +
						"UNION " +
					"SELECT fid, capacity FROM Flights WHERE fid = (?)");
		decrementCapacityStatement = conn.prepareStatement(
				"UPDATE Flights SET capacity = (?) WHERE fid = (?)");
				*/
		getReservationStatement = conn.prepareStatement(
				"SELECT rid, username, paid, day, flight1, flight2 FROM Reservations WHERE " +
						"username = (?)"
		);

		getRidStatement1 = conn.prepareStatement(
			"SELECT rid, username, flight1, flight2 FROM Reservations WHERE username = (?) AND " +
					"flight1 = (?) AND flight2 = (?)"
		);

		getRidStatement2 = conn.prepareStatement(
			"SELECT rid, username, flight1, flight2 FROM Reservations WHERE username = (?) AND " +
					"flight1 = (?)"
		);

		getReservationPayStatement = conn.prepareStatement(
				"SELECT rid, username, paid, flight1, flight2 FROM Reservations WHERE " +
						"rid = (?)"
		);



		updateBalanceStatement = conn.prepareStatement(
				"UPDATE Users SET balance = (?) WHERE username = (?)"
		);

		updatePaidStatement = conn.prepareStatement(
				"UPDATE Reservations SET paid = 1 WHERE rid = (?)"
		);

		getRsvPriceStatement = conn.prepareStatement(
		"SELECT a.rid, a.username, a.day, a.paid, a.flight1, a.flight2, a.price1, f2.price price2" +
		" FROM (SELECT r.rid, r.username, r.day, r.paid, r.flight1, r.flight2, f1.price price1" +
		" FROM Reservations r JOIN Flights f1 ON r.flight1 = f1.fid WHERE r.rid = (?)) " +
		"AS a LEFT JOIN Flights f2 ON a.flight2 = f2.fid"
		);

		getUserStatement = conn.prepareStatement("SELECT * FROM Users u WHERE u.username = ?");

		getReservationFlightStatement = conn.prepareStatement(
		  "SELECT r1.rid, r1.username, r1.paid, r1.flight1, r1.flight2, " +
                  "r1.fid1, f2.fid fid2, r1.day1, f2.day_of_month day2, r1.carrier1, f2" +
                  ".carrier_id carrier2, " +
                  "r1.fnum1, f2.flight_num fnum2, r1.origin_city1, f2.origin_city origin_city2, " +
                  "r1.dest_city1, f2.dest_city dest_city2, r1.time1, f2.actual_time time2, r1" +
                  ".capacity1, f2.capacity capacity2, r1.price1, f2.price price2 " +
                  "FROM (SELECT r.rid, r.username, r.paid, r.flight1, r.flight2, " +
                  "f1.fid fid1, f1.day_of_month day1, " +
                  "f1.carrier_id carrier1, f1.flight_num fnum1, " +
                  "f1.origin_city origin_city1, f1.dest_city dest_city1, " +
                  "f1.actual_time time1, f1.capacity capacity1, " +
                  "f1.price price1 " +
                  "FROM Reservations r, Flights f1 " +
                  "WHERE f1.fid = r.flight1 AND username = (?)) AS r1 LEFT JOIN " +
                  "Flights f2 ON r1.flight2 = f2.fid"
        );
	}


	/**
	 * Takes a user's username and password and attempts to log the user in.
	 *
	 * @return If someone has already logged in, then return "User already logged in\n"
	 * For all other errors, return "Login failed\n".
	 *
	 * Otherwise, return "Logged in as [username]\n".
	 */
	public String transaction_login(String username, String password)
	{
		if (loggedIn) {
			// loggedIn: boolean field
			return "User already logged in\n";
		}
		try {
			createLoginStatement.clearParameters();
			createLoginStatement.setString(1, username);
			createLoginStatement.setString(2, password);
			if (createLoginStatement.executeQuery().next()) {
				loggedIn = true;
				deleteItinerariesStatement.execute();
				this.username = username;
				return "Logged in as " + username + '\n';
			}
			throw new Exception();
		} catch (Exception e) {
			return "Login failed\n";
		}
	}

	/**
	 * Implement the create user function.
	 *
	 * @param username new user's username. User names are unique the system.
	 * @param password new user's password.
	 * @param initAmount initial amount to deposit into the user's account, should be >= 0 (failure otherwise).
	 *
	 * @return either "Created user {@code username}\n" or "Failed to create user\n" if failed.
	 */
	public String transaction_createCustomer (String username, String password, int initAmount)
	{
		try {
			if (initAmount < 0) throw new Exception();
			// createUserStmt: INSERT INTO Users (username, password, balance) VALUES (?, ?, ?)
			createUserStatement.clearParameters();
			createUserStatement.setString(1, username);
			createUserStatement.setString(2, password);
			createUserStatement.setInt(3, initAmount);
			createUserStatement.execute();
			return "Created user " + username + "\n";
		} catch (Exception e) {
			return "Failed to create user\n";
		}
	}

	/**
	 * Implements the book itinerary function.
	 *
	 * @param itineraryId ID of the itinerary to book. This must be one that is returned by search in the current session.
	 *
	 * @return If the user is not logged in, then return "Cannot book reservations, not logged in\n".
	 * If try to book an itinerary with invalid ID, then return "No such itinerary {@code itineraryId}\n".
	 * If the user already has a reservation on the same day as the one that they are trying to book now, then return
	 * "You cannot book two flights in the same day\n".
	 * For all other errors, return "Booking failed\n".
	 *
	 * And if booking succeeded, return "Booked flight(s), reservation ID: [reservationId]\n" where
	 * reservationId is a unique number in the reservation system that starts from 1 and increments by 1 each time a
	 * successful reservation is made by any user in the system.
	 */
	public String transaction_book(int itineraryId)
	{
		if (username == null) return "Cannot book reservations, not logged in\n";
		try {
			selectItineraryStatement.clearParameters();
			selectItineraryStatement.setInt(1, itineraryId);
			ResultSet itinerary = selectItineraryStatement.executeQuery();

			if (!itinerary.next()) return "No such itinerary " + itineraryId + '\n';
			int fid1 = itinerary.getInt("flight1");
			int fid2 = itinerary.getInt("flight2");
			// System.out.println(fid2);
			int day = itinerary.getInt("day_of_month");

			getReservationStatement.clearParameters();
			getReservationStatement.setString(1, username);
			ResultSet userReservations = getReservationStatement.executeQuery();
			while (userReservations.next()) {
				if (userReservations.getInt("day") == day) {
					return "You cannot book two flights in the same day\n";
				}
			}

			/*getCapacityStatement.clearParameters();
			getCapacityStatement.setInt(1, fid1);
			getCapacityStatement.setInt(2, fid2);
			ResultSet capacities = getCapacityStatement.executeQuery();*/
			try {
				beginTransaction();
			/*while (capacities.next()) {
				decrementCapacityStatement.clearParameters();
				int newCapacity = capacities.getInt("capacity") - 1;
				if (newCapacity < 0) {
					rollbackTransaction();
					break;
				}
				decrementCapacityStatement.setInt(1, newCapacity);
				decrementCapacityStatement.setInt(2, capacities.getInt("fid"));
				decrementCapacityStatement.execute();
			}*/

				if (fid2 != 0) {
					insertReservationStatement1.clearParameters();
					// insertReservationStatement1.setInt(1, rid + 1);
					insertReservationStatement1.setString(1, username);
					insertReservationStatement1.setInt(2, day);
					insertReservationStatement1.setInt(3, fid1);
					insertReservationStatement1.setInt(4, fid2);
					insertReservationStatement1.execute();

					getRidStatement1.clearParameters();
					getRidStatement1.setString(1, username);
					getRidStatement1.setInt(2, fid1);
					getRidStatement1.setInt(3, fid2);
					ResultSet getRid = getRidStatement1.executeQuery();
					if (getRid.next()) {
						int rid = getRid.getInt("rid");
						commitTransaction();
						return "Booked flight(s), reservation ID: " + rid + "\n";
					} else {
						throw new SQLException();
					}
				} else {
					insertReservationStatement2.clearParameters();
					// insertReservationStatement2.setInt(1, rid + 1);
					insertReservationStatement2.setString(1, username);
					insertReservationStatement2.setInt(2, day);
					insertReservationStatement2.setInt(3, fid1);
					insertReservationStatement2.execute();

					getRidStatement2.clearParameters();
					getRidStatement2.setString(1, username);
					getRidStatement2.setInt(2, fid1);
					ResultSet getRid = getRidStatement2.executeQuery();
					if (getRid.next()) {
						int rid = getRid.getInt("rid");
						commitTransaction();
						return "Booked flight(s), reservation ID: " + rid + "\n";
					} else {
						throw new SQLException();
					}
				}

				// rid++;
				// return "Booked flight(s), reservation ID: " + rid + "\n";

			} catch (SQLException e) {
				rollbackTransaction();
				throw e;
			}

		} catch (Exception e) {
		    e.printStackTrace();
			return "Booking failed\n";
		}
	}

	/**
	 * Implements the pay function.
	 *
	 * @param reservationId the reservation to pay for.
	 *
	 * @return If no user has logged in, then return "Cannot pay, not logged in\n"
	 * If the reservation is not found / not under the logged in user's name, then return
	 * "Cannot find unpaid reservation [reservationId] under user: [username]\n"
	 * If the user does not have enough money in their account, then return
	 * "User has only [balance] in account but itinerary costs [cost]\n"
	 * For all other errors, return "Failed to pay for reservation [reservationId]\n"
	 *
	 * If successful, return "Paid reservation: [reservationId] remaining balance: [balance]\n"
	 * where [balance] is the remaining balance in the user's account.
	 */
	public String transaction_pay (int reservationId)
	{
		if (!loggedIn) {
			return "Cannot pay, not logged in\n";
		}

		try {

			getReservationPayStatement.clearParameters();
			getReservationPayStatement.setInt(1, reservationId);
			ResultSet getReservation = getReservationPayStatement.executeQuery();
			if (!getReservation.next() ||
					!getReservation.getString("username").equals(username) ||
					getReservation.getInt("paid") == 1)
			{
				return "Cannot find unpaid reservation " + reservationId + " under user: " +
						username + "\n";
			}

			int balance;
			int amtToPay;

			getUserStatement.clearParameters();
			getUserStatement.setString(1, username);
			ResultSet user = getUserStatement.executeQuery();
			if (user.next()) {
			    balance = user.getInt("balance");
            } else {
			    throw new Exception();
            }

			getRsvPriceStatement.clearParameters();
			getRsvPriceStatement.setInt(1, reservationId);
			ResultSet getRsv = getRsvPriceStatement.executeQuery();
			if (getRsv.next()) {
                amtToPay = getRsv.getInt("price1") + getRsv.getInt("price2");
            } else {
			    throw new Exception();
            }
			if (amtToPay > balance) {
				return "User has only " + balance + " in account but itinerary costs " +
						amtToPay + "\n";
			}

			try {
				beginTransaction();
				updateBalanceStatement.clearParameters();
				updateBalanceStatement.setInt(1, balance - amtToPay);
				updateBalanceStatement.setString(2, username);
				updateBalanceStatement.execute();

				updatePaidStatement.clearParameters();
				updatePaidStatement.setInt(1, reservationId);
				updatePaidStatement.execute();

				commitTransaction();
				return "Paid reservation: " + reservationId + " remaining balance: " +
						(balance - amtToPay) + "\n";

			} catch (SQLException e) {
				rollbackTransaction();
				throw e;
			}

		} catch (Exception e) {
			e.printStackTrace();
			return "Failed to pay for reservation " + reservationId + "\n";
		}
	}

    class Flight {
        public int fid;
        public int dayOfMonth;
        public String carrierId;
        public String flightNum;
        public String originCity;
        public String destCity;
        public int time;
        public int capacity;
        public int price;

        public Flight(int fid, int dayOfMonth, String carrierId, String flightNum,
                                 String originCity, String destCity, int time, int capacity,
                                 int price) {
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

        public String toString()
        {
            return "ID: " + fid + " Day: " + dayOfMonth + " Carrier: " + carrierId +
                    " Number: " + flightNum + " Origin: " + originCity + " Dest: " + destCity + " Duration: " + time +
                    " Capacity: " + capacity + " Price: " + price;
        }
    }


	/**
	 * Implements the reservations function.
	 *
	 * @return If no user has logged in, then return "Cannot view reservations, not logged in\n"
	 * If the user has no reservations, then return "No reservations found\n"
	 * For all other errors, return "Failed to retrieve reservations\n"
	 *
	 * Otherwise return the reservations in the following format:
	 *
	 * Reservation [reservation ID] paid: [true or false]:\n"
	 * [flight 1 under the reservation]
	 * [flight 2 under the reservation]
	 * Reservation [reservation ID] paid: [true or false]:\n"
	 * [flight 1 under the reservation]
	 * [flight 2 under the reservation]
	 * ...
	 *
	 * Each flight should be printed using the same format as in the {@code Flight} class.
	 *
	 * @see Flight#toString()
	 */
	public String transaction_reservations()
	{
		if (!loggedIn) return "Cannot view reservations, not logged in\n";
		try {
			getReservationFlightStatement.clearParameters();
			getReservationFlightStatement.setString(1, username);
			ResultSet reservations = getReservationFlightStatement.executeQuery();
			int numReservations = 0;
			StringBuffer result = new StringBuffer();
			while (reservations.next()) {
			    int rid = reservations.getInt("rid");
			    String paid = (reservations.getInt("paid") == 0) ? "false" : "true";

			    String reservationString = "Reservation " + rid + " paid: " + paid + ":";

			    String flight1 = new Flight(reservations.getInt("fid1"),
                        reservations.getInt("day1"),
                        reservations.getString("carrier1"),
                        reservations.getString("fnum1"),
                        reservations.getString("origin_city1"),
                        reservations.getString("dest_city1"),
                        reservations.getInt("time1"),
                        reservations.getInt("capacity1"),
                        reservations.getInt("price1")).toString();

			    String flight2 = (reservations.getInt("fid2") == 0) ? "" : new Flight(
                        reservations.getInt("fid2"),
                        reservations.getInt("day2"),
                        reservations.getString("carrier2"),
                        reservations.getString("fnum2"),
                        reservations.getString("origin_city2"),
                        reservations.getString("dest_city2"),
                        reservations.getInt("time2"),
                        reservations.getInt("capacity2"),
                        reservations.getInt("price2")
                ).toString();

			    numReservations++;

			    result.append(reservationString).append('\n')
                        .append(flight1).append('\n')
                        .append(flight2);
			    if (flight2.length() > 0) result.append('\n');
            }

			if (numReservations == 0) return "No reservations found\n";
			return result.toString();

		} catch (Exception e) {
			e.printStackTrace();
			return "Failed to retrieve reservations\n";
		}
	}

	/**
	 * Implements the cancel operation.
	 *
	 * @param reservationId the reservation ID to cancel
	 *
	 * @return If no user has logged in, then return "Cannot cancel reservations, not logged in\n"
	 * For all other errors, return "Failed to cancel reservation [reservationId]"
	 *
	 * If successful, return "Canceled reservation [reservationId]"
	 *
	 * Even though a reservation has been canceled, its ID should not be reused by the system.
	 */
	public String transaction_cancel(int reservationId)
	{
		// only implement this if you are interested in earning extra credit for the HW!
		return "Failed to cancel reservation " + reservationId;
	}


	/* some utility functions below */

	public void beginTransaction() throws SQLException
	{
		conn.setAutoCommit(false);
		beginTransactionStatement.executeUpdate();
	}

	public void commitTransaction() throws SQLException
	{
		commitTransactionStatement.executeUpdate();
		conn.setAutoCommit(true);
	}

	public void rollbackTransaction() throws SQLException
	{
		rollbackTransactionStatement.executeUpdate();
		conn.setAutoCommit(true);
	}
}
