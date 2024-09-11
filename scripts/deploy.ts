import { config, network, run } from 'hardhat';
import { ethers } from 'hardhat';
async function main() {
  const eisenBadgeFactory = await ethers.getContractFactory('EisenBadge');
  const attesterProxyFactory = await ethers.getContractFactory('AttesterProxy');
  const easAddr = process.env.SCROLL_MAINNET_EAS_ADDRESS;
  let name = 'Eisen Hiker Level ';
  let symbol = 'Eisen Lv.';
  let uri = 'https://static.eisenfinance.com/scroll/scroll-canvas-';
  const resolver = process.env.SCROLL_MAINNET_BADGE_RESOLVER_ADDRESS;

  const deployerAddr = new ethers.Wallet(config.networks.scroll.accounts[0]).address;
  const signerAddr = new ethers.Wallet(process.env.SIGNER_PRIVATE_KEY ? process.env.SIGNER_PRIVATE_KEY : deployerAddr)
    .address;

  console.log(`Deployer address: ${deployerAddr}`);
  console.log(`Signer address: ${signerAddr}`);
  for (let i = 1; i < 5; i++) {
    const eisenBadge = await eisenBadgeFactory.deploy(name + i, symbol + i, uri + i + '.png', resolver);
    const WAIT_BLOCK_CONFIRMATIONS = 3;
    await eisenBadge.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
    console.log(`Contract deployed to ${eisenBadge.address} on ${network.name}`);
    console.log(`Verifying contract on Etherscan...`);

    await run(`verify:verify`, {
      address: eisenBadge.address,
      constructorArguments: [name + i, symbol + i, uri + i + '.png', resolver],
    });
  }
  const attesterProxy = await attesterProxyFactory.deploy(easAddr);
  const WAIT_BLOCK_CONFIRMATIONS = 3;
  await attesterProxy.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  console.log(`Contract deployed to ${attesterProxy.address} on ${network.name}`);
  console.log(`Verifying contract on Etherscan...`);

  await run(`verify:verify`, {
    address: attesterProxy.address,
    constructorArguments: [easAddr],
  });

  attesterProxy.connect(deployerAddr).toggleAttester(signerAddr, true);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
