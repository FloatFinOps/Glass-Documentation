# Virtual Machine Runtime Hours

This documentation explains the calculation of virtual machine Runtime Hours.

## 1. Data Source

The value for calculatiion comes from the `GetFinOpsSummaryVM` API.

### 2. Data Source Details

Within the API, it queries Azure to fetch back the runtime hours. The fetched value will be cached for 12 hours in backend for the same look back period, like 7 days, 30 days, etc. So, within the 12 hours, the data will not change, unless the API request tells it to reset the cache, which is not enabled for UI currently.

### 3. Azure Query

### 3.1 API

The API will use MetricsQueryClient to query runtime data, using filters as:

- `Granularity = 60 minutes`
- `TimeRange = lookBackPeriod`
- `Aggregations == { MetricAggregationType.Average, MetricAggregationType.Minimum, MetricAggregationType.Maximum, }`
Even though it returns 3 types of aggregations, current calculation is using `Average`. The `Average` value tells the acutal running time within the granularity time(in this case which is 1 hour), the value would be like 0.8 which means the virtual machine runs 0.8 hour within 1 hour.

After fetching the whole data, the calculation is:
a) get the whole availability from above result by:
    `vmAvailability` = vmMetrics.FirstOrDefault().TimeSeries.FirstOrDefault().Values;
    `LookBackPeriodHours` = `vmAvailability`.Count;
In the API response, the above values are assigned to `item.LookBackPeriodHours`, which represents the total look back period hours of selected virtual machine.

b) get the actual runtime by:
    `RunTimeHours` = `vmAvailability`.Sum(x => x.Average)
In the API response, the above values are assigned to `item.RunTimeHours`, which represents the total running hours of selected virtual machine.

### 3.2. UI Usage

In the UI, there is a `Loopback Period` option. When a Loopback Period is selected, the time value is converted into hours, and the final display of the cost value in the UI is:
    `Runtime Hours` = `item.RunTimeHours` / `item.LookBackPeriodHours`

Whenever the `Loopback Period` got changed, there will be a new API call to fetch the corresponding data.