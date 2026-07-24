import React, { useState } from 'react';
import {
  LogOut,
  CheckSquare,
  TrendingUp,
  UserPlus,
  Database,
  PlayCircle,
  ShieldCheck,
  Building2,
} from 'lucide-react';
import { AppUser } from '../types';

interface MenuUtamaScreenProps {
  currentUser: AppUser;
  onLogout: () => void;
  onNavigate: (screen: 'misi' | 'atur_misi' | 'hasil' | 'user' | 'data') => void;
}

export const MenuUtamaScreen: React.FC<MenuUtamaScreenProps> = ({
  currentUser,
  onLogout,
  onNavigate,
}) => {
  const [showLogoutDialog, setShowLogoutDialog] = useState(false);

  const tiles = [
    {
      id: 'atur_misi' as const,
      label: 'Atur misi',
      icon: CheckSquare,
      iconBg: 'bg-[#E5E8F5]',
      iconColor: 'text-[#16225C]',
      description: 'Tugaskan kategori ke auditor',
      adminOnly: false,
    },
    {
      id: 'hasil' as const,
      label: 'Hasil',
      icon: TrendingUp,
      iconBg: 'bg-[#E1F5EE]',
      iconColor: 'text-[#0F6E56]',
      description: 'Statistik & akurasi stok',
      adminOnly: false,
    },
    {
      id: 'user' as const,
      label: 'Create user',
      icon: UserPlus,
      iconBg: 'bg-[#FDF1D6]',
      iconColor: 'text-[#92670A]',
      description: 'Manajemen akun user',
      adminOnly: false,
    },
    {
      id: 'data' as const,
      label: 'Data',
      icon: Database,
      iconBg: 'bg-[#FBE6E7]',
      iconColor: 'text-[#B3131A]',
      description: 'Export & Upload XLSX',
      adminOnly: false,
    },
  ];

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-4 sm:p-6">
      <div className="w-full max-w-[640px] mx-auto flex flex-col flex-1">
        {/* Top Header Bar */}
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
              MENU UTAMA
            </span>
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-white/80 text-[#16225C] border border-[#DDE4F0]">
              <Building2 size={11} /> Mitra10
            </span>
          </div>
          <button
            id="btn-logout"
            onClick={() => setShowLogoutDialog(true)}
            className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#B3131A] hover:bg-red-50 transition-colors shadow-sm"
            title="Keluar"
          >
            <LogOut size={16} />
          </button>
        </div>

        {/* Main Card */}
        <div className="bg-white rounded-[28px] p-5 sm:p-7 flex-1 flex flex-col shadow-sm">
          {/* User Welcome */}
          <div className="flex items-start justify-between border-b border-[#DDE4F0] pb-5">
            <div>
              <span className="text-[13px] text-[#5B688A]">Selamat bertugas,</span>
              <h1 className="text-[22px] sm:text-[24px] font-bold text-[#172554] mt-0.5">
                {currentUser.name}
              </h1>
              <div className="flex items-center gap-2 mt-1">
                <span className="inline-flex items-center gap-1 text-[11px] font-medium text-[#5B688A]">
                  <ShieldCheck size={13} className="text-[#16225C]" />
                  {currentUser.role === 'admin' ? 'Administrator' : `Auditor · ${currentUser.category || 'Umum'}`}
                </span>
              </div>
            </div>

            <div className="w-11 h-11 rounded-2xl bg-[#E5E8F5] text-[#16225C] font-bold flex items-center justify-center text-base">
              {currentUser.name.split(' ').map((n) => n[0]).join('').substring(0, 2).toUpperCase()}
            </div>
          </div>

          {/* Quick Mission Action for Client Auditors */}
          {currentUser.category && (
            <div className="mt-5 p-4 bg-[#16225C] text-white rounded-2xl flex items-center justify-between">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-[#F5B301]">
                  Misi Aktif Hari Ini
                </span>
                <h3 className="text-[15px] font-semibold mt-0.5">
                  Kategori {currentUser.category}
                </h3>
              </div>
              <button
                id="btn-start-misi"
                onClick={() => onNavigate('misi')}
                className="inline-flex items-center gap-1.5 bg-[#F5B301] hover:bg-[#e0A300] text-[#172554] px-4 py-2 rounded-xl text-[13px] font-bold transition-colors shadow-sm"
              >
                <PlayCircle size={16} /> Mulai Misi
              </button>
            </div>
          )}

          {/* Menu Tiles Grid */}
          <div className="mt-5 flex-1 flex flex-col justify-center">
            <span className="text-[12px] font-bold text-[#5B688A] mb-3 uppercase tracking-wider">
              Fitur Utama
            </span>
            <div className="grid grid-cols-2 gap-3.5">
              {tiles.map((tile) => {
                const Icon = tile.icon;
                return (
                  <button
                    key={tile.id}
                    id={`menu-tile-${tile.id}`}
                    onClick={() => onNavigate(tile.id)}
                    className="p-4 bg-[#F4F7FC] hover:bg-[#EBEEFA] border border-[#DDE4F0] rounded-[20px] text-left flex flex-col justify-between transition-all group hover:border-[#16225C]"
                  >
                    <div className={`w-10 h-10 rounded-xl ${tile.iconBg} flex items-center justify-center transition-transform group-hover:scale-105`}>
                      <Icon className={tile.iconColor} size={20} />
                    </div>
                    <div className="mt-4">
                      <span className="block text-[14px] font-semibold text-[#172554]">
                        {tile.label}
                      </span>
                      <span className="block text-[11px] text-[#5B688A] mt-0.5 line-clamp-1">
                        {tile.description}
                      </span>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      {/* Logout Confirmation Modal */}
      {showLogoutDialog && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-[340px] w-full shadow-xl text-center animate-in fade-in zoom-in-95 duration-150">
            <h3 className="text-[17px] font-bold text-[#172554]">Keluar akun?</h3>
            <p className="text-[13px] text-[#5B688A] mt-2">
              Kamu akan kembali ke halaman login.
            </p>
            <div className="flex gap-3 mt-6">
              <button
                id="btn-logout-cancel"
                onClick={() => setShowLogoutDialog(false)}
                className="flex-1 py-2.5 border border-[#DDE4F0] rounded-xl text-[14px] font-medium text-[#172554] hover:bg-gray-50"
              >
                Batal
              </button>
              <button
                id="btn-logout-confirm"
                onClick={() => {
                  setShowLogoutDialog(false);
                  onLogout();
                }}
                className="flex-1 py-2.5 bg-[#B3131A] hover:bg-red-700 text-white rounded-xl text-[14px] font-medium"
              >
                Keluar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
