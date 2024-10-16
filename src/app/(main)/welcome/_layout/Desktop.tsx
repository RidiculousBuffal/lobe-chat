import { GridShowcase } from '@lobehub/ui';
// import { LobeHub } from '@lobehub/ui/brand';
import { PropsWithChildren } from 'react';
import { Flexbox } from 'react-layout-kit';

const COPYRIGHT = `© ${new Date().getFullYear()} CathayBot LLC`;

const DesktopLayout = ({ children }: PropsWithChildren) => {
  return (
    <>
      <Flexbox
        align={'center'}
        height={'100%'}
        justify={'space-between'}
        padding={16}
        style={{ overflow: 'hidden', position: 'relative' }}
        width={'100%'}
      >
        <h2 style={{ alignSelf: 'flex-start' }}>Cathay Bot</h2>
        {/*<LobeHub size={36} style={{ alignSelf: 'flex-start' }} type={'text'} />*/}
        <GridShowcase
          innerProps={{ gap: 24 }}
          style={{ maxHeight: 'calc(100% - 104px)', maxWidth: 1024 }}
          width={'100%'}
        >
          {children}
        </GridShowcase>
        <Flexbox align={'center'} horizontal justify={'space-between'}>
          <span style={{ opacity: 0.5 }}>{COPYRIGHT}</span>
        </Flexbox>
      </Flexbox>
      {/* ↓ cloud slot ↓ */}

      {/* ↑ cloud slot ↑ */}
    </>
  );
};

export default DesktopLayout;
