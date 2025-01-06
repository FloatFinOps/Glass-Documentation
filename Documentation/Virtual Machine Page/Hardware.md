# Virtual Machine Hardware Cost, Reservation, Saving Calculation, Breakeven Runtime Percentage

This documentation explains the calculation of virtual machine hardware Cost, Reservation, Saving, Breakeven Runtime Percentage.

## 1. Data Source

The value for calculatiion comes from the `GetFinOpsSummaryVM` API.

### 2. Data Source Details

There is an import process that inserts/updates the Azure price sheet list into the database on a monthly schedule. The table where this data is stored is named `MA_RetailPriceList`. All cost values are fetched from this table and are further calculated based on location, SKU, resource type, time frame, etc.

### 3. Cost

### 3.1 API

The logic to fetch the original price information from the database uses the following filters:

- `ArmRegionName == virtual machine's ArmLocation`
- `ArmSkuName == virtual machine's SKU`
- `ProductName == "Virtual Machines"`
- `SkuName != "Spot"`
- `SkuName != "Low Priority"`
- `Type == "Consumption"`
- `ProductName` does not end with "Windows"
- Order by `EffectiveStartDate`, and fetch the latest record.

In the API response, the above values are assigned to `item.HardwareCommitent.HardwarePaygCost`, which represents the 1-hour cost of the selected virtual machine.

### 3.2. UI Usage

In the UI, there is a `Time Frame` option. When a time frame is selected, the time value is converted into hours, and the final display of the cost value in the UI is:
`Hardware Cost` = vm.hardwareCommitent.hardwarePaygCost.retailPrice * (timeFrameData in hour)

#### Time Frame Example:

[
    { "timeFrame": "1 Hour", "value": 1 },
    { "timeFrame": "1 Day", "value": 24 },
    { "timeFrame": "1 Week", "value": 168 },
    { "timeFrame": "1 Month", "value": 720 },
    { "timeFrame": "1 Year", "value": 8640 }
]

### 4. Reservation

### 4.1 API

The logic to fetch the original price information from the database uses the following filters:

- `ArmRegionName == virtual machine's ArmLocation`
- `ArmSkuName == virtual machine's SKU`
- `ProductName == "Virtual Machines"`
- `SkuName != "Spot"`
- `SkuName != "Low Priority"`
- `Type == "Reservation"`
- `ProductName` does not end with "Windows"
- as reservation has 2 terms: `1 Year` & `3 Years`, return both for further process.

In the API response, the above values are assigned to `item.HardwareCommitent.reservationsPaygCost` as a collection, which will be used in UI.

### 4.2. UI Usage

In the UI, there is a `Commitment Periods` option. When a period is selected, the period value (exmaple: '1 YRS') is mapped to match up with database record (example: 'license1Year'), and the final display of the reservation cost value in the UI is: 

based on period selection, calculation is different as below:  
1 year cost for 1 year term = vm.hardwareCommitent.reservationsPaygCost.retailPrice  
1 year cost for 3 years term = vm.hardwareCommitent.reservationsPaygCost.retailPrice / 3  

`Reservation Cost` = ((1 year cost) / 8640) * (timeFrameData in hour)

*8640 is the total hour of 1 year

#### Commitment Periods Example:

[
    {name : '1 YRS', value: 'license1Year'},
    {name : '3 YRS', value: 'license3Year'}
]

### 5. Saving

After the calculation of Cost and Reservation as above, then with the same time frame, the calculation of saving is:
`Saving` = `Hardware Cost` - `Reservation Cost`

### 6. Breakeven RunTime Percentage

### 6.1 API

After fetching the Hardware Cost and Reservation Cost from the database, refer to step of 3.1 and 4.1, the breakeven calculation is:
breakEvenRunTimePercentage = (reservation.RetailPrice / cost.RetailPrice) / HOURS_IN_1_YEARS

In the API response, the above values are assigned to `item.HardwareCommitent.reservationsPaygCost.breakEvenRunTimePercentage` as a collection for 1/3 years term, which will be used in UI.

### 6.2 UI
In the UI, there is a `Commitment Periods` option. When a period is selected, the period value (exmaple: '1 YRS') is mapped to match up with database record (example: 'license1Year'), and the final display of the breakeven runTime percentage value in the UI is to find the matched value from API, then display it.
