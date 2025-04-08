import os
import subprocess
from datetime import datetime

def execute_audit_script(script_path):
    try:
        # Make the script executable
        os.chmod(script_path, 0o755)
        # Execute the script and capture output
        result = subprocess.run(['bash', script_path], 
                              capture_output=True, 
                              text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def main():
    # Get all .sh files in the current directory
    audit_scripts = [f for f in os.listdir('.') if f.endswith('.sh')]
    
    # Initialize counters
    successful = 0
    failed = 0
    total = len(audit_scripts)
    
    # Create a log file with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = f"audit_results_{timestamp}.log"
    
    print(f"Starting audit execution. Total scripts to run: {total}")
    
    with open(log_file, 'w', encoding='utf-8') as log:
        log.write(f"Audit Execution Report - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log.write("=" * 50 + "\n\n")
        
        for script in sorted(audit_scripts):
            print(f"Executing {script}...")
            success, stdout, stderr = execute_audit_script(script)
            
            # Update counters
            if success:
                successful += 1
            else:
                failed += 1
            
            # Log the results
            log.write(f"\nScript: {script}\n")
            log.write("-" * 30 + "\n")
            log.write(f"Status: {'SUCCESS' if success else 'FAILED'}\n")
            if stdout:
                log.write("\nOutput:\n")
                log.write(stdout)
            if stderr:
                log.write("\nErrors:\n")
                log.write(stderr)
            log.write("\n" + "=" * 50 + "\n")
            
            # Print progress
            print(f"Progress: {successful + failed}/{total} scripts completed")
    
    # Print final summary
    print("\nAudit Execution Summary:")
    print(f"Total scripts executed: {total}")
    print(f"Successful: {successful}")
    print(f"Failed: {failed}")
    print(f"\nDetailed results have been saved to: {log_file}")

if __name__ == "__main__":
    main()
