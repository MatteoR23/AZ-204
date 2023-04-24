# Imposta le tue credenziali di accesso ad Azure
$subscriptionId = "Pay-as-you-go"
$resourceGroupName = "az-204-rg"
$location = "westeurope"
$adminUsername = "matteo"
$adminPassword = "Casmeo23!"

# Imposta le informazioni sulla macchina virtuale
$vmName = "az-204-win"
$vmSize = "Standard_B1s"
$imagePublisher = "MicrosoftWindowsServer"
$imageOffer = "WindowsServer"
$imageSKU = "2019-Datacenter"
$nicName = "az-204-nic"
$vnetName = "az-204-vnet"
$vnetResourceGroupName = $resourceGroupName
$subnetName = "az-204-subnet"
$publicIpAddressName = "az-204-ip"
$rdpPort = "3389"

# Autenticazione e selezione dell'account di Azure
Connect-AzAccount

# Seleziona la sottoscrizione di Azure
Select-AzSubscription -SubscriptionId $subscriptionId

New-AzResourceGroup -Name $resourceGroupName -Location "westeurope"

# Crea una regola per la porta RDP
$rdpRule = New-AzNetworkSecurityRuleConfig -Name "AllowRDP" -Protocol Tcp `
    -Direction Inbound -Priority 1000 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange $rdpPort `
    -Access Allow

# Crea un indirizzo IP pubblico
$publicIpAddress = New-AzPublicIpAddress -Name $publicIpAddressName `
    -ResourceGroupName $resourceGroupName -Location $location `
    -AllocationMethod Dynamic

# Crea una scheda di rete
$nic = New-AzNetworkInterface -Name $nicName `
    -ResourceGroupName $resourceGroupName -Location $location `
    -SubnetId "/subscriptions/$subscriptionId/resourceGroups/$vnetResourceGroupName/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName" `
    -PublicIpAddressId $publicIpAddress.Id -NetworkSecurityGroup $nsg

# Crea la macchina virtuale
New-AzVM -Name $vmName -ResourceGroupName $resourceGroupName -Location $location `
    -VirtualNetworkName $vnetName -SubnetName $subnetName -PublicIpAddressName $publicIpAddressName `
    -SecurityGroupName $nsgName -OpenPorts $rdpRule -ImagePublisher $imagePublisher `
    -ImageOffer $imageOffer -ImageSKU $imageSKU -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, (ConvertTo-SecureString $adminPassword -AsPlainText -Force))) `
    -Size $vmSize
