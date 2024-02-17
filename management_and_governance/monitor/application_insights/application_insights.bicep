// *****************************************************************************
//
// File:        application-insights.bicep
//
// Description: Creates a Log Analytics Workspace and an Application Insights
//              Component.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// *****************************************************************************

@description('The type of application being monitored.')
@allowed([
  'other'
  'web'
])
param applicationInsightsApplicationType string = 'web'

@description('The name of the Application Insights Component.')
param applicationInsightsComponentName string

@description('The kind of application that this component refers to, used to customize UI.')
@allowed([
  'ios'
  'java'
  'other'
  'phone'
  'store'
  'web'
])
param applicationInsightsKind string = 'web'

@description('The data retention period in days for Application Insights.')
@allowed([
  30
  31
  60
  90
  120
  180
  270
  365
  550
  730
])
param applicationInsightsRetentionInDays int = 90

@description('Indicates if a Log Analytics Workspace should be created/updated specifically for this Application Insights Component.')
param createUpdateLogAnalyticsWorkspace bool = false

@description('The daily volume cap for ingestion in GB.')
@minValue(-1)
param dailyQuotaInGB int = -1

@description('Indicates if the workspace is accessed using only resource, and not workspace, permissions.')
param enableLogAccessUsingOnlyResourcePermissions bool = true

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The data retention period in days for Log Analytics.')
@allowed([
  30
  31
  60
  90
  120
  180
  270
  365
  550
  730
])
param logAnalyticsRetentionInDays int = 30

@description('The name of the Log Analytics Workspace.')
@minLength(4)
@maxLength(63)
param logAnalyticsWorkspaceName string

@description('The network access type for accessing ingestion.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('The network access type for accessing query.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

// If a separate, pre-existing Log Analytics Workspace should be used, get the resource and do not update
// any properties on it.
resource logAnalyticsWorkspaceSeparate 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (!createUpdateLogAnalyticsWorkspace) {
  name: logAnalyticsWorkspaceName
  location: location
}

// If a Log Analytics Workspace specific to the Application Insights Component should be used, create or update it.
resource logAnalyticsWorkspaceAppi 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (createUpdateLogAnalyticsWorkspace) {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    features: {
      enableLogAccessUsingOnlyResourcePermissions: enableLogAccessUsingOnlyResourcePermissions
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    retentionInDays: logAnalyticsRetentionInDays
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaInGB
    }
  }
}

// Update the retention period on the Application Insights tables.
var tableNames = [
  'AppAvailabilityResults'
  'AppBrowserTimings'
  'AppDependencies'
  'AppEvents'
  'AppExceptions'
  'AppMetrics'
  'AppPageViews'
  'AppPerformanceCounters'
  'AppRequests'
  'AppSystemEvents'
  'AppTraces'
]

resource table 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = [for tableName in tableNames: if (createUpdateLogAnalyticsWorkspace) {
  name: tableName
  parent: logAnalyticsWorkspaceAppi
  properties: {
    retentionInDays: applicationInsightsRetentionInDays
  }
}]

// Create an Application Insights Component.
resource applicationInsightsComponent 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsComponentName
  location: location
  kind: applicationInsightsKind
  properties:{
    Application_Type: applicationInsightsApplicationType
    Flow_Type: 'Bluefield'
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    Request_Source: 'rest'
    WorkspaceResourceId: ((createUpdateLogAnalyticsWorkspace)? logAnalyticsWorkspaceAppi.id : logAnalyticsWorkspaceSeparate.id)
  }
}
