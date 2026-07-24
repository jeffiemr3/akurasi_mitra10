import React, { useState } from 'react';
import { ArrowLeft, UserPlus, Search, Trash2, Shield, Power, Check } from 'lucide-react';
import { AppUser } from '../types';

interface ManajemenUserScreenProps {
  users: AppUser[];
  onBack: () => void;
  onAddUserClick: () => void;
  onToggleUserStatus: (userId: string) => void;
  onDeleteUser: (userId: string) => void;
}

export const ManajemenUserScreen: React.FC<ManajemenUserScreenProps> = ({
  users,
  onBack,
  onAddUserClick,
  onToggleUserStatus,
  onDeleteUser,
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null);

  const filteredUsers = users.filter(
    (u) =>
      u.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      u.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (u.category && u.category.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-4 sm:p-6">
      <div className="w-full max-w-[640px] mx-auto flex flex-col flex-1">
        {/* Header Bar */}
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            <button
              id="btn-user-mgmt-back"
              onClick={onBack}
              className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#172554] hover:bg-gray-50"
            >
              <ArrowLeft size={16} />
            </button>
            <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
              MANAJEMEN USER
            </span>
          </div>

          <button
            id="btn-add-user"
            onClick={onAddUserClick}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-[#16225C] text-white rounded-xl text-[12px] font-semibold hover:bg-[#1F2E75] shadow-xs"
          >
            <UserPlus size={14} /> + User Baru
          </button>
        </div>

        {/* Content Card */}
        <div className="bg-white rounded-[28px] p-5 sm:p-7 flex-1 flex flex-col shadow-sm">
          <div>
            <h1 className="text-[20px] font-bold text-[#172554]">Manajemen User</h1>
            <p className="text-[12px] text-[#5B688A] mt-0.5">
              Daftar akun auditor dan administrator Mitra10
            </p>
          </div>

          {/* Search Box */}
          <div className="mt-4 relative">
            <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#5B688A]" />
            <input
              type="text"
              placeholder="Cari berdasarkan nama, username, atau kategori..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-3.5 py-2.5 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[13px] text-[#172554] focus:outline-none focus:border-[#16225C]"
            />
          </div>

          {/* User List */}
          <div className="mt-4 flex-1 space-y-2.5 overflow-y-auto max-h-[420px] pr-1">
            {filteredUsers.map((u) => {
              const initials = u.name
                .split(' ')
                .map((n) => n[0])
                .join('')
                .substring(0, 2)
                .toUpperCase();

              return (
                <div
                  key={u.id}
                  className="p-3.5 bg-[#FAF9F5] border border-[#DDE4F0] rounded-2xl flex items-center justify-between gap-3 hover:border-[#16225C] transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-[#E5E8F5] text-[#16225C] font-bold flex items-center justify-center text-[13px]">
                      {initials}
                    </div>
                    <div>
                      <div className="flex items-center gap-1.5">
                        <span className="text-[14px] font-bold text-[#172554]">
                          {u.name}
                        </span>
                        <span
                          className={`px-2 py-0.5 rounded-md text-[9.5px] font-bold uppercase ${
                            u.role === 'admin'
                              ? 'bg-[#FDF1D6] text-[#92670A]'
                              : 'bg-[#E1F5EE] text-[#0F6E56]'
                          }`}
                        >
                          {u.role}
                        </span>
                      </div>

                      <div className="text-[11.5px] text-[#5B688A] mt-0.5">
                        @{u.username} · {u.role === 'admin' ? 'Admin · semua kategori' : (u.category || '-')}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    {/* Active/Idle Status Toggle */}
                    <button
                      id={`btn-toggle-status-${u.id}`}
                      onClick={() => onToggleUserStatus(u.id)}
                      className={`px-2.5 py-1 rounded-full text-[11px] font-bold flex items-center gap-1 ${
                        u.status === 'active'
                          ? 'bg-[#E1F5EE] text-[#0F6E56] hover:bg-emerald-200'
                          : 'bg-gray-200 text-gray-600 hover:bg-gray-300'
                      }`}
                      title="Klik untuk ubah status active/idle"
                    >
                      <Power size={11} /> {u.status}
                    </button>

                    {/* Delete button (cannot delete main admin) */}
                    {u.username !== 'admin' && (
                      <button
                        id={`btn-delete-${u.id}`}
                        onClick={() => setDeleteConfirmId(u.id)}
                        className="w-7 h-7 rounded-lg text-[#B3131A] hover:bg-[#FBE6E7] flex items-center justify-center"
                        title="Hapus user"
                      >
                        <Trash2 size={15} />
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Delete Confirmation Dialog */}
      {deleteConfirmId && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-[340px] w-full shadow-xl text-center">
            <h3 className="text-[16px] font-bold text-[#172554]">Hapus User Ini?</h3>
            <p className="text-[12.5px] text-[#5B688A] mt-1.5">
              Akun ini tidak akan dapat digunakan lagi untuk login.
            </p>
            <div className="flex gap-2.5 mt-5">
              <button
                onClick={() => setDeleteConfirmId(null)}
                className="flex-1 py-2.5 border border-[#DDE4F0] rounded-xl text-[13px] font-medium text-[#172554]"
              >
                Batal
              </button>
              <button
                onClick={() => {
                  onDeleteUser(deleteConfirmId);
                  setDeleteConfirmId(null);
                }}
                className="flex-1 py-2.5 bg-[#B3131A] text-white rounded-xl text-[13px] font-medium"
              >
                Hapus
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
