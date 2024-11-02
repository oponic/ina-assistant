import javax.swing.*;
import java.awt.*;
import java.io.*;
import java.net.*;
import java.nio.file.*;

public class InaInstaller {
    private JFrame frame;
    private JProgressBar progressBar;
    private JTextArea logArea;
    private JButton installButton;
    
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
                // Check Java
                log("Checking Java installation...");
                String javaVersion = System.getProperty("java.version");
                log("Found Java " + javaVersion);
                progressBar.setValue(10);
                
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
                progressBar.setValue(20);
                
                // Download files
                log("Downloading INA files...");
                URL url = URI.create("https://example-data.net/data.zip").toURL();
                String zipPath = installDir + "/ina.zip";
                try (InputStream in = url.openStream()) {
                    Files.copy(in, Paths.get(zipPath), StandardCopyOption.REPLACE_EXISTING);
                }
                progressBar.setValue(60);
                
                // Extract files
                log("Extracting files...");
                ProcessBuilder pb = new ProcessBuilder("unzip", "-o", zipPath, "-d", installDir);
                pb.start().waitFor();
                Files.delete(Paths.get(zipPath));
                progressBar.setValue(80);
                
                // Create launcher
                log("Creating launcher script...");
                String launcher = binDir + "/ina";
                String script = "#!/bin/bash\njava -jar \"" + installDir + "/ina.jar\" \"$@\"";
                Files.write(Paths.get(launcher), script.getBytes());
                
                if (!osName.contains("windows")) {
                    new File(launcher).setExecutable(true);
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
