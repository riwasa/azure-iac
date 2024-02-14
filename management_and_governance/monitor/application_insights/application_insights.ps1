# *****************************************************************************
#
# File:        monitor.ps1
#
# Description: Creates an Application Insights Component, and if necessary,
#              a Log Analytics Workspace.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# *****************************************************************************

# Get script variables.
$resourceGroupName = ""
$location = ""

$applicationInsightsComponentName = ""
$logAnalyticsWorkspaceName = ""

# Check if the Log Analytics Workspace already exists. Suppress any error messages.
$lawExists = $null -ne (az monitor log-analytics workspace show `
  --resource-group $resourceGroupName --workspace-name $logAnalyticsWorkspaceName `
  --query "id" -o tsv 2>$null)

Write-Host "Log Analytics Workspace already exists: $lawExists"

# Create an Application Insights Component, and if necessary, a Log Analytics Workspace.
if ($lawExists) {
  Write-Host "Creating an Application Insights Component"
  Write-Host "Note that properties will not be updated on the existing Log Analytics Workspace"
} else {
  Write-Host "Creating a Log Analytics Workspace and an Application Insights Component"
}

az deployment group create `
  --name "application_insights" `
  --resource-group "$resourceGroupName" `
  --template-file "application_insights.bicep" `
  --parameters "application_insights.parameters.json" `
  --parameters applicationInsightsComponentName=$applicationInsightsComponentName `
               location=$location `
               logAnalyticsWorkspaceExists=$lawExists `
               logAnalyticsWorkspaceName=$logAnalyticsWorkspaceName
