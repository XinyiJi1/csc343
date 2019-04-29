import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        try {
            // note: variable connection defined in JDBCSubmission
            connection = DriverManager.getConnection(url, username, password);
            String setPath = "SET SEARCH_PATH to parlgov;";
//            Statement statement = connection.createStatement();
//            statement.execute(setPath);
//            statement.close();
            PreparedStatement statement = connection.prepareStatement(setPath);
            statement.executeUpdate();
        }
        catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    @Override
    public boolean disconnectDB() {
        try {
            connection.close();
        }
        catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        List<Integer> elections = new ArrayList<Integer>();
        List<Integer> cabinets = new ArrayList<Integer>();
        try {
            String query = "SELECT election.id, cabinet.id " +
                    "FROM cabinet, country, election " +
                    "WHERE election.country_id = country.id " +
                    "AND election.id = cabinet.election_id " +
                    "AND country.name = ? " +
                    "ORDER BY election.e_date DESC, cabinet.start_date ASC;";
            PreparedStatement statement = connection.prepareStatement(query);
            statement.setString(1, countryName);
            //statement.executeUpdate();
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                elections.add(rs.getInt(1));
                cabinets.add(rs.getInt(2));
            }
        }
        catch (SQLException e) {
            e.printStackTrace();
            return null;
        }

        ElectionCabinetResult result = new ElectionCabinetResult(elections, cabinets);
        return result;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        List<Integer> result = new ArrayList<Integer>();
        String desCom = "";
        String comDes = "";

        try {
            String politician = "SELECT id, description, comment FROM politician_president WHERE id = ?;";
            PreparedStatement s1 = connection.prepareStatement(politician);
            s1.setInt(1, politicianName);
            //s1.executeUpdate();
            ResultSet r1 = s1.executeQuery();
            while (r1.next()) {
                desCom = r1.getString(2) + r1.getString(3);
                comDes = r1.getString(3) + r1.getString(2);
            }

            String others = "SELECT id, description, comment FROM politician_president WHERE id <> ?;";
            PreparedStatement s2 = connection.prepareStatement(others);
            s2.setInt(1, politicianName);
            //s2.executeUpdate();
            ResultSet r2 = s2.executeQuery();
            String des = "";
            String com = "";
            while (r2.next()) {
                des = r2.getString(2);
                com = r2.getString(3);
                if (similarity(desCom, des + com) >= threshold || similarity(comDes, com + des) >= threshold) {
                    result.add(r2.getInt(1));
                }
            }
        }
        catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
        return result;
    }

    //public static void main(String[] args) throws ClassNotFoundException {
    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
//         Assignment2 test = new Assignment2();
//
//         test.connectDB(
//             "jdbc:postgresql://localhost:5432/csc343h-zhuange2?currentSchema=parlgov",
//             "zhuange2", "");
//
//         // Test election sequence
//         System.out.println("Test 1:");
//         ElectionCabinetResult a = test.electionSequence("Canada");
//         for(int i = 0; i < a.elections.size(); ++i) {
//             System.out.println("Election: " + a.elections.get(i) + " Cabinet: " + a.cabinets.get(i));
//         }
//
//         // Test findSimilarPoliticians
//         List<Integer> b = test.findSimilarPoliticians(9, (float)0.0);
//         System.out.println("Test 2:");
//         for(int i : b) {
//             System.out.println(i);
//         }
//
//         test.disconnectDB();
    }

}

