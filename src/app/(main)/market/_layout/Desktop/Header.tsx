'use client';

import { ChatHeader } from '@lobehub/ui';
// import { LobeChat } from '@lobehub/ui/brand';
import { createStyles } from 'antd-style';
import { memo } from 'react';

// import { ProductLogo } from '@/components/Branding';
import ShareAgentButton from '../../features/ShareAgentButton';

export const useStyles = createStyles(({ css, token }) => ({
  logo: css`
    color: ${token.colorText};
    fill: ${token.colorText};
  `,
}));

const Header = memo(() => {
  // const { styles } = useStyles();

  return (
    <ChatHeader
      left={<h2 style={{ fontWeight: '800' }}>Cathay Bot</h2>}
      right={<ShareAgentButton />}
    />
  );
});

export default Header;
