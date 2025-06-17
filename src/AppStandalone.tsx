import React, { Fragment, useEffect, useState } from "react";
import { Spinner } from "@patternfly/react-core";
import { Container } from "@migration-planner-ui/ioc";
import { Provider as DependencyInjectionProvider } from "@migration-planner-ui/ioc";
import { Configuration } from "@migration-planner-ui/api-client/runtime";
import { AgentApi } from "@migration-planner-ui/agent-client/apis";
import { ImageApi, SourceApi } from "@migration-planner-ui/api-client/apis";
import Routing from "./Routing";
import { Symbols } from "./main/Symbols";

// 🔁 Replaces useChrome() + createAuthFetch()
const mockAuthFetch = async (input: RequestInfo, init?: RequestInit): Promise<Response> => {
  return fetch(input, init);
};

const AppStandalone = () => {
  const [container, setContainer] = useState<Container>();

  useEffect(() => {
    const configure = () => {
      const plannerApiConfig = new Configuration({
        basePath: '/api/migration-assessment',
        fetchApi: mockAuthFetch,
      });

      const c = new Container();
      c.register(Symbols.ImageApi, new ImageApi(plannerApiConfig));
      c.register(Symbols.SourceApi, new SourceApi(plannerApiConfig));
      c.register(Symbols.AgentApi, new AgentApi(plannerApiConfig));

      setContainer(c);
    };

    configure();
  }, []);

  if (!container) {
    return <Spinner />;
  }

  return (
    <Fragment>
      <DependencyInjectionProvider container={container}>
        <React.Suspense fallback={<Spinner />}>
          <Routing />
        </React.Suspense>
      </DependencyInjectionProvider>
    </Fragment>
  );
};

export default AppStandalone;
