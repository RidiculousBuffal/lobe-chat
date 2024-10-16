'use client';

// import { LobeHub } from '@lobehub/ui/brand';
import { createStyles } from 'antd-style';
import Link from 'next/link';
import { memo } from 'react';
import { Flexbox, FlexboxProps } from 'react-layout-kit';

// import { UTM_SOURCE } from '@/const/url';

const useStyles = createStyles(({ token, css }) => ({
  logoLink: css`
    height: 20px;
    color: inherit;

    &:hover {
      color: ${token.colorLink};
    }
  `,
}));

const BrandWatermark = memo<Omit<FlexboxProps, 'children'>>(({ style, ...rest }) => {
  const { styles, theme } = useStyles();
  return (
    <Flexbox
      align={'center'}
      flex={'none'}
      gap={4}
      horizontal
      style={{ color: theme.colorTextDescription, fontSize: 12, ...style }}
      {...rest}
    >
      <span>Powered by</span>
      <Link className={styles.logoLink} href={`https://www.cathaycapital.com/`} target={'_blank'}>
        {/*<LobeHub size={20} type={'text'} />*/}
        <h2 style={{ fontSize: '12px', fontWeight: '800', marginTop: '2px' }}>Cathay Bot</h2>
      </Link>
    </Flexbox>
  );
});

export default BrandWatermark;
