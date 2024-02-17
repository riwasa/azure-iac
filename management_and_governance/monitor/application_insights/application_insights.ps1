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

# Create an Application Insights Component, and if specified, a Log Analytics Workspace.
Write-Host "Creating an Application Insights Component, and if specified, a Log Analytics Workspace."

az deployment group create `
  --name "application_insights" `
  --resource-group "$resourceGroupName" `
  --template-file "application_insights.bicep" `
  --parameters "application_insights.parameters.json" `
  --parameters applicationInsightsComponentName=$applicationInsightsComponentName `
               location=$location `
               logAnalyticsWorkspaceName=$logAnalyticsWorkspaceName
