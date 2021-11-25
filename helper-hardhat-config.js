const networkConfig = {
    31337: {
        name: 'localhost',
        keyHash: '0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311', 
        fee: '100000000000000000',
        oracle: '0x0DB2363890527738cDe621dF7BB69C2C4aB7ccEc', 
        jobId: '29fa9aa13bf1468788b7cc4a500a45b8', 
        fund: '200000000000000000'
    },
    4: {
        name: 'rinkeby', 
        linkToken: '0x01BE23585060835E02B77ef475b0Cc51aA1e0709', 
        vrfCoordinator: '0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B',
        keyHash: '0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311', 
        fee: '100000000000000000',
        oracle: '0xCE3DB86C2130B7D83a1E946f8856ba7b629A3F00', 
        jobId: '0x06a1aed457cb4938b0d5f928ff9f328f'
    },
    80001: {
        name: 'mumbai',
        linkToken: '0x326C977E6efc84E512bB9C30f76E30c160eD06FB',
        keyHash: '0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4',
        vrfCoordinator: '0x8C7382F9D8f56b33781fE506E897a4F1e2d17255',
        oracle: '0x0DB2363890527738cDe621dF7BB69C2C4aB7ccEc', 
        jobId: '0x54bd0a3d8fb54da6bd8da32b17912ed3',
        backupjobId: '54bd0a3d8fb54da6bd8da32b17912ed3',
        fee: '100000000000000'
    }
}

module.exports = {
    networkConfig
}

