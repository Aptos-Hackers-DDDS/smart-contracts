import { useState, useEffect } from "react";
import { Layout, Row, Col, Button } from "antd";
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design";
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";
import { Provider, Network } from "aptos";
import { useWallet } from "@aptos-labs/wallet-adapter-react";

const provider = new Provider(Network.DEVNET);

function App() {
  const { account } = useWallet();
  useEffect(() => {
    fetchList();
  }, [account?.address]);
  const [accountHasList, setAccountHasList] = useState<boolean>(false);

  const fetchList = async () => {
    if (!account) return [];
    // change this to be your module account address
    const moduleAddress = "0x2b3a3c5d2118343dbda316b94fe93c36a4a4130d9084ae24366b398c7774b18d";
    try {
      const TodoListResource = await provider.getAccountResource(
        account.address,
        `${moduleAddress}::todolist::TodoList`
      );
      setAccountHasList(true);
    } catch (e: any) {
      setAccountHasList(false);
    }
  };

  return (
    <>
      <Layout>
        <Row align="middle">
          <Col span={10} offset={2}>
            <h1>Our todolist</h1>
          </Col>
          <Col span={12} style={{ textAlign: "right", paddingRight: "200px" }}>
            <WalletSelector />
          </Col>
        </Row>
      </Layout>
      {!accountHasList && (
        <Row gutter={[0, 32]} style={{ marginTop: "2rem" }}>
          <Col span={8} offset={8}>
            <Button block type="primary" style={{ height: "40px", backgroundColor: "#3f67ff" }}>
              Add new list
            </Button>
          </Col>
        </Row>
      )}
    </>
  );
}

export default App;
