import javax.swing.*;
import java.awt.*;
import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.util.*;

public class InaInstaller {
    private JFrame frame;
    private JProgressBar progressBar;
    private JTextArea logArea;
    private JButton installButton;
    
    private static final List<String> PYTHON_DEPS = Arrays.asList(
        "groq",
        "requests"
    );
    
    private static final List<String> PERL_DEPS = Arrays.asList(
        "JSON",
        "LWP::UserAgent",
        "File::Find",
        "HTTP::Request"
    );
    
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new InaInstaller().createAndShowGUI());
    }
    
    private void createAndShowGUI() {
        frame = new JFrame("INA Assistant Installer");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(500, 400);
        frame.setLayout(new BorderLayout(10, 10));
        
        // Header
        JPanel headerPanel = new JPanel();
        headerPanel.add(new JLabel("INA Assistant Installer"));
        frame.add(headerPanel, BorderLayout.NORTH);
        
        // Center panel with progress and log
        JPanel centerPanel = new JPanel(new BorderLayout(5, 5));
        progressBar = new JProgressBar(0, 100);
        progressBar.setStringPainted(false);
        centerPanel.add(progressBar, BorderLayout.NORTH);
        
        logArea = new JTextArea(10, 40);
        logArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(logArea);
        centerPanel.add(scrollPane, BorderLayout.CENTER);
        frame.add(centerPanel, BorderLayout.CENTER);
        
        // Install button
        JPanel buttonPanel = new JPanel();
        installButton = new JButton("Install");
        installButton.addActionListener(e -> startInstallation());
        buttonPanel.add(installButton);
        frame.add(buttonPanel, BorderLayout.SOUTH);
        
        // Center on screen
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }
    
    private void log(String message) {
        SwingUtilities.invokeLater(() -> {
            logArea.append(message + "\n");
            logArea.setCaretPosition(logArea.getDocument().getLength());
        });
    }
    
    private void startInstallation() {
        installButton.setEnabled(false);
        new Thread(() -> {
            try {
                // Check Python
                log("Checking Python installation...");
                ProcessBuilder pythonCheck = new ProcessBuilder("python3", "--version");
                Process pythonProc = pythonCheck.start();
                if (pythonProc.waitFor() != 0) {
                    throw new Exception("Python 3 is not installed!");
                }
                progressBar.setValue(5);

                // Check pip
                log("Checking pip installation...");
                ProcessBuilder pipCheck = new ProcessBuilder("pip3", "--version");
                Process pipProc = pipCheck.start();
                if (pipProc.waitFor() != 0) {
                    throw new Exception("pip3 is not installed!");
                }
                progressBar.setValue(10);

                // Install Python dependencies
                log("Installing Python dependencies...");
                for (String dep : PYTHON_DEPS) {
                    log("Installing " + dep + "...");
                    ProcessBuilder pb = new ProcessBuilder("pip3", "install", "--user", dep);
                    pb.redirectErrorStream(true);
                    Process p = pb.start();
                    
                    try (BufferedReader reader = new BufferedReader(
                            new InputStreamReader(p.getInputStream()))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            log(line);
                        }
                    }
                    
                    if (p.waitFor() != 0) {
                        throw new Exception("Failed to install " + dep);
                    }
                }
                progressBar.setValue(30);

                // Check Perl
                log("Checking Perl installation...");
                ProcessBuilder perlCheck = new ProcessBuilder("perl", "--version");
                Process perlProc = perlCheck.start();
                if (perlProc.waitFor() != 0) {
                    throw new Exception("Perl is not installed!");
                }
                progressBar.setValue(35);

                // Install cpanm if not present
                log("Checking/Installing cpanm...");
                ProcessBuilder cpanmCheck = new ProcessBuilder("cpanm", "--version");
                if (cpanmCheck.start().waitFor() != 0) {
                    log("Installing cpanm...");
                    ProcessBuilder installCpanm = new ProcessBuilder("curl", "-L", 
                        "https://cpanmin.us", "|", "perl", "-", "--sudo", "App::cpanminus");
                    if (installCpanm.start().waitFor() != 0) {
                        throw new Exception("Failed to install cpanm");
                    }
                }
                progressBar.setValue(40);

                // Install Perl dependencies
                log("Installing Perl dependencies...");
                for (String dep : PERL_DEPS) {
                    log("Installing " + dep + "...");
                    ProcessBuilder pb = new ProcessBuilder("cpanm", dep);
                    pb.redirectErrorStream(true);
                    Process p = pb.start();
                    
                    try (BufferedReader reader = new BufferedReader(
                            new InputStreamReader(p.getInputStream()))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            log(line);
                        }
                    }
                    
                    if (p.waitFor() != 0) {
                        throw new Exception("Failed to install " + dep);
                    }
                }
                progressBar.setValue(50);

                // Check Java
                log("Checking Java installation...");
                String javaVersion = System.getProperty("java.version");
                log("Found Java " + javaVersion);
                progressBar.setValue(60);
                
                // Determine install paths
                String osName = System.getProperty("os.name").toLowerCase();
                String userHome = System.getProperty("user.home");
                String installDir, binDir;
                
                if (osName.contains("mac")) {
                    installDir = userHome + "/Library/Application Support/ina";
                    binDir = "/usr/local/bin";
                } else if (osName.contains("windows")) {
                    installDir = System.getenv("APPDATA") + "/ina";
                    binDir = userHome + "/bin";
                } else {
                    installDir = userHome + "/.local/share/ina";
                    binDir = userHome + "/.local/bin";
                }
                
                log("Installing to: " + installDir);
                Files.createDirectories(Paths.get(installDir));
                Files.createDirectories(Paths.get(binDir));
                progressBar.setValue(70);
                
                // Download files
                log("Downloading INA files...");
                URL url = URI.create("https://example-data.net/data.zip").toURL();
                String zipPath = installDir + "/ina.zip";
                try (InputStream in = url.openStream()) {
                    Files.copy(in, Paths.get(zipPath), StandardCopyOption.REPLACE_EXISTING);
                }
                progressBar.setValue(90);
                
                // Extract files
                log("Extracting files...");
                ProcessBuilder pb = new ProcessBuilder("unzip", "-o", zipPath, "-d", installDir);
                pb.start().waitFor();
                Files.delete(Paths.get(zipPath));
                progressBar.setValue(100);
                
                // Create launcher
                log("Creating launcher script...");
                String launcher = binDir + "/ina";
                String script = "#!/bin/bash\njava -jar \"" + installDir + "/ina.jar\" \"$@\"";
                Files.write(Paths.get(launcher), script.getBytes());
                
                if (!osName.contains("windows")) {
                    new File(launcher).setExecutable(true);
                }
                
                // Create .key file
                log("Setting up API key...");
                String keyPath = installDir + "/.key";
                String apiKey = JOptionPane.showInputDialog(frame, 
                    "Please enter your Groq API key:",
                    "API Key Required",
                    JOptionPane.QUESTION_MESSAGE);
                
                if (apiKey != null && !apiKey.trim().isEmpty()) {
                    Files.write(Paths.get(keyPath), apiKey.trim().getBytes());
                    log("API key saved successfully.");
                } else {
                    log("Warning: No API key provided. You'll need to set it manually later.");
                }
                
                progressBar.setValue(100);
                log("\nInstallation complete! You can now run 'ina' from your terminal.");
                log("Make sure " + binDir + " is in your PATH.");
                
                JOptionPane.showMessageDialog(frame, 
                    "Installation completed successfully!", 
                    "Success", 
                    JOptionPane.INFORMATION_MESSAGE);
                
            } catch (Exception e) {
                log("Error: " + e.getMessage());
                StringWriter sw = new StringWriter();
                e.printStackTrace(new PrintWriter(sw));
                log("Stack trace: " + sw.toString());
                
                JOptionPane.showMessageDialog(frame,
                    "Installation failed: " + e.getMessage(),
                    "Error",
                    JOptionPane.ERROR_MESSAGE);
            } finally {
                installButton.setEnabled(true);
            }
        }).start();
    }
}
