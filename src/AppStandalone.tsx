import React, { Fragment, useEffect, useState } from 'react';
import { Spinner, Page, PageHeader } from '@patternfly/react-core';
import { Main } from '@redhat-cloud-services/frontend-components';
import { Container } from '@migration-planner-ui/ioc';
import { Provider as DependencyInjectionProvider } from '@migration-planner-ui/ioc';
import { Configuration } from '@migration-planner-ui/api-client/runtime';
import { AgentApi } from '@migration-planner-ui/agent-client/apis';
import { ImageApi, SourceApi } from '@migration-planner-ui/api-client/apis';
import Routing from './Routing';
import { Symbols } from './main/Symbols';

// 👉 Include styles manually
import '@patternfly/react-core/dist/styles/base.css';
import '@redhat-cloud-services/frontend-components/index.css'; // if used in prod

// 👉 Simple fetch to replace createAuthFetch in standalone mode
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
    <Page header={<PageHeader logo="Migration Planner" />}>
      <Main>
        <DependencyInjectionProvider container={container}>
          <React.Suspense fallback={<Spinner />}>
            <Routing />
          </React.Suspense>
        </DependencyInjectionProvider>
      </Main>
    </Page>
  );
};

export default AppStandalone;
